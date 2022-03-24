class Room < ApplicationRecord
  has_many :room_users, dependent: :destroy
  has_many :users, through: :room_users
  has_many :messages, dependent: :destroy


  def self.room_exists?(user_ids)
    user1 = User.find(user_ids[0].id)
    user2 = User.find(user_ids[1].id)
    # user1.roomsとuser2.roomsの両方に属するroomオブジェクトが存在すればfound_roomに代入する
    found_room = nil
    user2.rooms.each do |room|
      if user1.rooms.include?(room)
        found_room = room
      end
    end
    return found_room
  end
end