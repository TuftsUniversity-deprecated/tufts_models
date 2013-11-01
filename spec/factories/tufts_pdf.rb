FactoryGirl.define do
  factory :tufts_pdf do
    ignore do
      user { FactoryGirl.create(:user) }
    end
    sequence(:title) {|n| "Title #{n}" }
    before(:create) { |deposit, evaluator|
      deposit.apply_depositor_metadata(evaluator.user.user_key)
    }
    rights { 'http://dca.tufts.edu/ua/access/rights-creator.html' }
  end
end
