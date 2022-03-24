class UsersController < ApplicationController

  def show
    @user = User.find(params[:id])
    @trips = @user.trips
  end

  def follow_list
    @room = Room.new
    @user = User.find(params[:id])
    @relationship = Relationship.new
    if user_signed_in?
      user_ids = [current_user, @user]
      @room_exist = Room.room_exists?(user_ids)
    end
  end
end
