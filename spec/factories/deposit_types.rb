require 'factory_girl'

FactoryGirl.define do
  factory :deposit_type do
    sequence(:id)
    sequence(:display_name) {|n| "Deposit Type No. #{n}" }
    deposit_view 'generic_deposit'
    deposit_agreement 'legal jargon here...'
  end
end
