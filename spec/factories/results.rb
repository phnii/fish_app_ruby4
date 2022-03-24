FactoryBot.define do
  factory :result do
    fish_name {'テストウオ'}
    image {Faker::Lorem.sentence}
    association :trip

    after(:build) do |result|
      result.image.attach(io: File.open("#{Rails.root}/spec/system/images/test_image.png"), filename: 'test_image.png')
    end
  end
end