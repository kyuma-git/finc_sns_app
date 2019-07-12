FactoryBot.define do
  factory :user do

    sequence(:name)  { |n| "sample#{n}" }
    sequence(:email) { |n| "tester#{n}@example.com" }
    password {'password'}

    #has_many関係のアソシエーション
    factory :group do
      posts {[
      FactoryBot.build(:post, group: nil)
      ]}
    end
    
  end
end
