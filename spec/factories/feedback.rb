FactoryBot.define do
  factory :feedback do
    experience

    rating { [*1..5].sample }
    user_ip { Faker::Internet.ip_v4_address }
  end
end
