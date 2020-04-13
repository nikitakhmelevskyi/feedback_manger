FactoryBot.define do
  factory :feedback do
    experience

    rating { [*1..5].sample }
  end
end
