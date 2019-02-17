# -----------------------------------------------------------------------------------------------------------------------------
# セレクタ
# -----------------------------------------------------------------------------------------------------------------------------
form_selector       = '[data-form]'
content_selector    = '[data-content]'
picture_selector    = '[data-picture]'
send_selector       = '[data-send]'
modal_wrap_selector = '.iziModal-wrap'
messages_selector   = 'ul.messages'

# -----------------------------------------------------------------------------------------------------------------------------
# 関数
# -----------------------------------------------------------------------------------------------------------------------------
# フォームクリア
clear_form = (selector) ->
  $(selector).find(":text, :file").val("")
  return

# 最下底にスクロール
scroll_bottom = (targetSelector) ->
  $(targetSelector).scrollTop($(targetSelector).get(0).scrollHeight)

# fileのDATA URLを取得
get_reader = (file) ->
  reader = new FileReader()
  reader.readAsDataURL(file)
  return reader

# 既に購読しているチャンネルかどうかチェックする
check_subscribe = (channel, room_id) ->
  result = false
  subscriptions = App.cable.subscriptions['subscriptions']
  subscriptions.forEach (subscription) ->
    identifier = subscription.identifier
    json = JSON.parse(identifier)
    if json.channel == channel && json.room_id == room_id
      result = true
  return result

# ダイレクトメッセージ送信
send_dm = ->
  content = $.trim($(content_selector).val())
  picture = $(picture_selector).get(0).files[0]

  has_content = if content.length > 0 then true else false
  has_picture = if (picture != undefined && picture != null) then true else false

  if has_content || has_picture
    if has_picture
      file_name = picture.name
      reader    = get_reader(picture)
      reader.addEventListener "loadend", ->
        App.room.send_dm(content, reader.result, file_name)
    else
        App.room.send_dm(content)

# サブスクリプション生成
create_subscriptions = ->
  channel  = "RoomChannel"
  room_id = $(form_selector).data("room-id")
  current_user_id = $(form_selector).data("current-user-id")
  # 既に購読済みチャンネルならcreate_subscriptionsしない。
  # これがないと、ブラウザバックした後、戻ってきた時に同じチャンネルを
  # ２重で購読し、メッセージを２重で受信してしまう
  unless check_subscribe(channel, room_id)
    # クライアント側でApp.cable.subscriptions.createが呼ばれると
    # サーバのチャンネルと通信が始まる？
    # paramsはapp/channels/room_channel.rbに渡される。
    # room_channel.rbの中でparams['room_id']等でアクセスできる。
    params = { channel: channel, room_id: room_id, current_user_id: current_user_id }
    App.room = App.cable.subscriptions.create (params),
      connected: ->
        # Called when the subscription is ready for use on the server
    
      disconnected: ->
        # Called when the subscription has been terminated by the server
    
      received: (data) ->
        html = data['html']
        if params['current_user_id'] != data['sent_by']
          html = html.replace("right_side","left_side")
        $(messages_selector).append(html)
        scroll_bottom(modal_wrap_selector)
    
      send_dm: (content, data_uri, file_name) ->
        @perform('send_dm', { content: content, data_uri: data_uri, file_name: file_name })
        clear_form(form_selector)

# -----------------------------------------------------------------------------------------------------------------------------
# イベント関数
# -----------------------------------------------------------------------------------------------------------------------------
modal_scroll_event = ->
  $(modal_wrap_selector).on 'scroll', (event) ->
    if cmn_scroll_top(event.target)
      console.log('scroll win')

click_send_event = ->
  $(send_selector).on 'click', (event) ->
    send_dm()
    event.preventDefault()

enter_send_event = ->
  $(content_selector).on 'keypress', (event) ->
    if event.which is 13 # = Enter
      send_dm()
      event.preventDefault()

# -----------------------------------------------------------------------------------------------------------------------------
# app/views/direct_messages/_index.html.slim読み込み時処理
# -----------------------------------------------------------------------------------------------------------------------------
$(document).on 'direct_messages__index_loaded', (event) ->
  create_subscriptions()
  setTimeout (-> scroll_bottom(modal_wrap_selector)), 500
  modal_scroll_event()
  click_send_event()
  enter_send_event()
