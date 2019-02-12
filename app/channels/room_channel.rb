class RoomChannel < ApplicationCable::Channel
  # このクラス内で使用するparamsは
  # app/assets/javascripts/channels/room.coffeeの
  # App.cable.subscriptions.create (params)で渡された
  # paramsから来ている
  def subscribed
    # 引数のチャンネル名のストリームを購読する
    #stream_from "room_channel_#{params['room_id']}"

    # 引数のモデルに紐付いたチャンネルのストリームを購読する
    #stream_for Room.find(params['room_id'])
    stream_for current_user
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def send_dm(data)
    room = current_user.rooms.find(params['room_id'])
    content = data['content']
    picture_data_uri = data['data_uri']
    direct_message = current_user.send_dm(room, content, picture_data_uri)

    # 第一引数のチャンネル名に対してブロードキャストする
    #ActionCable.server.broadcast("room_channel_#{params['room_id']}", cast_data(direct_message))
    
    # 第一引数のモデルに紐付いたチャンネルに対してブロードキャストする
    if direct_message.errors.any?
      # エラーがあったら、現在のユーザにのみブロードキャストする
      RoomChannel.broadcast_to(current_user, cast_data(direct_message))
    else
      room = Room.find(params['room_id'])
      room.users.each do |user|
        RoomChannel.broadcast_to(user, cast_data(user,direct_message))
      end
    end
  end

  private

    def cast_data(user,direct_message)
      {
        html: ApplicationController.renderer.render(
                partial: 'direct_messages/direct_message',
                locals: { 
                  direct_message: direct_message,
                  current_user_id: user.id
                })
      }
    end
end
