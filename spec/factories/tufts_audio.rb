FactoryGirl.define do
  factory :tufts_audio do
    ignore do
      user { FactoryGirl.create(:user) }
    end
    sequence(:title) {|n| "Title #{n}" }
    after(:build) { |deposit, evaluator|
      deposit.apply_depositor_metadata(evaluator.user.display_name)
    }
  end
end

