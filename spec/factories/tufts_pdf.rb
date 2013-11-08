FactoryGirl.define do
  factory :tufts_pdf do
    ignore do
      user { FactoryGirl.create(:user) }
    end
    sequence(:title) {|n| "Title #{n}" }
    after(:build) { |deposit, evaluator|
      deposit.apply_depositor_metadata(evaluator.user.display_name)
    }
    rights { 'http://dca.tufts.edu/ua/access/rights-creator.html' }

  end

  factory :self_deposit_pdf, parent: :tufts_pdf do
    ignore do
      user { FactoryGirl.create(:user) }
    end
    createdby Contribution::SELFDEP
    after(:build) do |deposit, evaluator|
      deposit.note = "#{evaluator.user.display_name} self-deposited on #{Time.now.strftime('%Y-%m-%d at %H:%M:%S %Z')} using the Deposit Form for the Tufts Digital Library"
    end
  end
end

