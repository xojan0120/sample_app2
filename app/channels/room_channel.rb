class RoomChannel < ApplicationCable::Channel
  # このクラス内で使用するparamsは
  # app/assets/javascripts/channels/room.coffeeの
  # App.cable.subscriptions.create (params)で渡された
  # paramsから来ている
  def subscribed
    stream_from "room_channel_#{params['room_id']}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def send_dm(data)
    room = current_user.rooms.find(params['room_id'])
    content = data['content']
    picture = data['data_uri']
    # pictureをdata uri形式で登録できるようにする！
    # 要carrier wave data uri plugin gem
    dm = current_user.send_dm(room, content, picture)
    ActionCable.server.broadcast("room_channel_#{params['room_id']}", cast_data(dm))
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
