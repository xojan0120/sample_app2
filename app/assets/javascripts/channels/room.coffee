# -----------------------------------------------------------------------------------------------------------------------------
# セレクタ定義
# -----------------------------------------------------------------------------------------------------------------------------
form_selector    = '#message_input_form'
content_selector = '#js-content'
picture_selector = '#js-picture'
send_selector    = '#js-send'

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

send_dm = ->
  content = $.trim($(content_selector).val())
  picture = $(picture_selector).get(0).files[0]

  has_content = if content.length   >  0          then true else false
  has_picture = if typeof(picture) != 'undefined' then true else false

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
  # paramsはapp/channels/room_channel.rbに渡される。
  # room_channel.rbの中でparams['room_id']等でアクセスできる。
  App.room = App.cable.subscriptions.create (params),
    connected: ->
      # Called when the subscription is ready for use on the server
  
    disconnected: ->
      # Called when the subscription has been terminated by the server
  
    received: (data) ->
      $('#messages').prepend(data['message_html'])
  
    send_dm: (content, data_uri, file_name) ->
      #@perform('send_dm', { content: content, data_uri: data_uri, file_name: file_name })
      alert "send!"
      clear_form(form_selector)

# -----------------------------------------------------------------------------------------------------------------------------
# イベント定義
# -----------------------------------------------------------------------------------------------------------------------------
# channel_room_create_subscriptionsはapp/views/direct_messages/_index.html.slimの
# 下部のtriggerメソッド用のカスタムイベントである。_index.html.slimが読み込まれたら
# create_subscriptionsする。理由は、_index.html.slim内のform要素のdata-room-id属性に
# room-idを持たせており、その要素がレンダリングされたあとで無いと、ここで欲しいroom_idが
# 取得できないため。
$(document).on 'channel_room_create_subscriptions', ->
  room_id = $(form_selector).data("room-id")
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
