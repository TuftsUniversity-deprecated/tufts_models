FactoryGirl.define do
  factory :personal_collection do
    transient do
      user { FactoryGirl.create(:user) }
    end
    sequence(:title) {|n| "Title #{n}" }
    after(:build) { |deposit, evaluator|
      deposit.apply_depositor_metadata(evaluator.user)
      deposit.active_user = evaluator.user
    }
  end
end
