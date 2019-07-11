FactoryBot.define do
  factory :post do
    text {'test'}
    association :user
  end
end
