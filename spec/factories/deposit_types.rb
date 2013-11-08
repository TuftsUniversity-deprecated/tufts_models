require 'factory_girl'

FactoryGirl.define do
  factory :deposit_type do
    sequence(:display_name) {|n| "Deposit Type No. #{n}" }
    deposit_view 'generic_deposit'
    deposit_agreement 'legal jargon here...'
    license_name 'Generic Deposit Agreement v1.0'
    sequence(:source) {|n| "Source #{n}" }
  end
end
