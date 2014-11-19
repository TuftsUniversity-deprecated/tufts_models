FactoryGirl.define do
  factory :tufts_audio do
    transient do
      user { FactoryGirl.create(:user) }
    end
    displays { ['dl'] }
    sequence(:title) {|n| "Title #{n}" }
    after(:build) { |deposit, evaluator|
      deposit.apply_depositor_metadata(evaluator.user.email)
    }
  end
end

