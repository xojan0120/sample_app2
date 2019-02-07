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
    #room = current_user.rooms.find(session[:room_id])
    #content = params[:direct_message][:content]
    #picture = params[:direct_message][:picture]
    #@direct_message = current_user.send_dm(room, content, picture)
  end
end
