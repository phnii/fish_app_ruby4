FactoryBot.define do
  factory :user do
    name {Faker::Name.initials(number: 2)}
    email {Faker::Internet.free_email}
    introduce {Faker::Lorem.sentence}
    password = Faker::Internet.password(min_length: 6)
    password {password}
    password_confirmation {password}
  end
end