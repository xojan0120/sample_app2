class RoomChannel < ApplicationCable::Channel
  # このクラス内で使用するparamsは
  # app/assets/javascripts/channels/room.coffeeの
  # App.cable.subscriptions.create (params)で渡された
  # paramsから来ている
  def subscribed
    # 引数のチャンネル名のストリームを購読する
    #stream_from "room_channel_#{params['room_id']}"

    # 引数のモデルに紐付いたチャンネルのストリームを購読する
    stream_for Room.find(params['room_id'])
    stream_for current_user
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def send_dm(data)
    room = current_user.rooms.find(params['room_id'])
    content = data['content']
    picture_data_uri = data['data_uri']
    dm = current_user.send_dm(room, content, picture_data_uri)

    # 第一引数のチャンネル名に対してブロードキャストする
    #ActionCable.server.broadcast("room_channel_#{params['room_id']}", cast_data(dm))
    
    # 第一引数のモデルに紐付いたチャンネルに対してブロードキャストする
    if dm.errors.any?
      RoomChannel.broadcast_to(current_user, cast_data(dm))
    else
      RoomChannel.broadcast_to(Room.find(params['room_id']), cast_data(dm))
    end
  end

  private

    def cast_data(dm)
      {
        html: ApplicationController.renderer.render(
                partial: 'direct_messages/direct_message',
                locals: { dm: dm })
      }
    end
end
