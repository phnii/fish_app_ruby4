class RoomsController < ApplicationController
  def create
    room_users = User.where(room_params[:user_ids])
    user_ids = [room_users[0], room_users[1]]
    found_room = Room.room_exists?(user_ids)
    if found_room
      redirect_to room_messages_path(found_room)
    else
      @room = Room.new(room_params)
      @room.save
      redirect_to room_messages_path(@room)
    end
  end

  private

  def room_params
    params.require(:room).permit(user_ids: [])
  end
end
