FactoryGirl.define do
  factory :course_collection do
    ignore do
      user { FactoryGirl.create(:user) }
    end
    sequence(:title) {|n| "Title #{n}" }
    after(:build) { |deposit, evaluator|
      deposit.apply_depositor_metadata(evaluator.user)
    }
  end
end

