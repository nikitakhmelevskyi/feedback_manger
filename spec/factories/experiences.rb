FactoryBot.define do
  factory :experience do
    name { Faker::Lorem.sentence(word_count: 3) }
  end
end
