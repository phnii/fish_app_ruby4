user = User.new(
  email: "guest@guest.com",
  name: "guestuser",
  password: "guetpass123"
)
user.save!

Trip.create!(
  title: "海釣り日記",
  prefecture_id: 10,
  content: "釣りに行ってきた",
  user_id: 1,
)