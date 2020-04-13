FactoryBot.define do
  factory :responses do
    feedback
    question

    answer { Faker::Lorem.sentence(word_count: 3) }
  end
end
