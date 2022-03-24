FactoryBot.define do
  factory :comment do
    content {Faker::Lorem.sentence}
    association :user
    association :trip
  end
end