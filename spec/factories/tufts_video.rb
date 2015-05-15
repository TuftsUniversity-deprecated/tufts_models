FactoryGirl.define do
  factory :tufts_video do
    transient do
      user { FactoryGirl.create(:user) }
    end
    sequence(:title) {|n| "Title #{n}" }
    displays { ['dl'] }
    after(:build) { |deposit, evaluator|
      deposit.apply_depositor_metadata(evaluator.user.display_name)
    }
    rights { ['http://dca.tufts.edu/ua/access/rights-creator.html'] }
  end
end
