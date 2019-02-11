# -----------------------------------------------------------------------------------------------------------------------------
# セレクタ定義
# -----------------------------------------------------------------------------------------------------------------------------
form_selector    = '[data-form]'
content_selector = '[data-content]'
picture_selector = '[data-picture]'
send_selector    = '[data-send]'

# -----------------------------------------------------------------------------------------------------------------------------
# 関数定義
# -----------------------------------------------------------------------------------------------------------------------------
clear_form = (selector) ->
  $(selector).find(":text, :file").val("")
  return

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

  return

create_subscriptions = (params) ->
  # クライアント側でApp.cable.subscriptions.createが呼ばれると
  # サーバのチャンネルと通信が始まる？
  # paramsはapp/channels/room_channel.rbに渡される。
  # room_channel.rbの中でparams['room_id']等でアクセスできる。
  App.room = App.cable.subscriptions.create (params),
    connected: ->
      # Called when the subscription is ready for use on the server
  
    disconnected: ->
      # Called when the subscription has been terminated by the server
  
    received: (data) ->
      $('ul.messages').append(data['html'])
  
    send_dm: (content, data_uri, file_name) ->
      @perform('send_dm', { content: content, data_uri: data_uri, file_name: file_name })
      clear_form(form_selector)

# -----------------------------------------------------------------------------------------------------------------------------
# イベント定義
# -----------------------------------------------------------------------------------------------------------------------------
# channel_room_create_subscriptionsはapp/views/direct_messages/_index.html.slimの
# 下部のtriggerメソッド用のカスタムイベントである。_index.html.slimが読み込まれたら
# create_subscriptionsする。理由は、_index.html.slim内のform要素のdata-room-id属性に
# room-idを持たせており、その要素がレンダリングされたあとで無いと、ここで欲しいroom_idが
# 取得できないため。
$(document).on 'channels_room_create_subscriptions', ->
  room_id = $(form_selector).data("room-id")
  # 既に購読済みチャンネルならcreate_subscriptionsしない。
  # これがないと、ブラウザバックした後、戻ってきた時に同じチャンネルを
  # ２重で購読し、メッセージを２重で受信してしまう
  unless check_subscribe("RoomChannel",room_id)
    create_subscriptions({ channel: "RoomChannel", room_id: room_id })

$(document).on 'keypress', content_selector, (event) ->
  if event.which is 13 # = Enter
    send_dm()
    event.preventDefault()
  return

$(document).on 'click', send_selector, (event) ->
  send_dm()
  event.preventDefault()
  return
