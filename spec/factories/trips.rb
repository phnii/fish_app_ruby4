FactoryBot.define do
  factory :trip do
    title {Faker::Lorem.sentence}
    content {Faker::Lorem.sentence}
    prefecture { Prefecture.all.find(id=2)}
    association :user
  end
end