FactoryBot.define do
  factory :question do
    experience

    text { Faker::Lorem.sentence(word_count: 3) }
  end
end
