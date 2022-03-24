class MessagesController < ApplicationController
  before_action :authenticate_user!
  def index
    @room = Room.find(params[:room_id])
    @messages = Message.where(room_id: @room.id).order('created_at DESC')
    @message = Message.new
    room_users = Room.find(params[:room_id]).users
    @mutural_follow  = false

    unless room_users.include?(current_user)
      redirect_to root_path
    end

    if room_users[0].following?(room_users[1]) && room_users[1].following?(room_users[0])
      @mutural_follow = true
    end
  end

  def create
    @room = Room.find(params[:room_id])
    @message = Message.new(message_params)
    if @message.save
      redirect_to room_messages_path(@room.id)
    else
      redirect_to room_messages_path(@room.id)
    end
  end

  private

  def message_params
    params.require(:message).permit(:content).merge(user_id: current_user.id, room_id: params[:room_id])
  end



end
