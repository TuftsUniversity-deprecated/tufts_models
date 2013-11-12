require 'factory_girl'

FactoryGirl.define do
  factory :deposit_type do
    sequence(:display_name) {|n| "Deposit Type No. #{n}" }
    deposit_view 'generic_deposit'
    deposit_agreement 'legal jargon here...'
    license_name 'Generic Deposit Agreement v1.0'
    sequence(:source) {|n| "Source_#{n}" }
    before(:create) do |deposit_type|
      pid = "tufts:UA069.001.DO.#{deposit_type.source}"
      unless TuftsEAD.exists?(pid)
        TuftsEAD.create!(pid: pid, title: "Test #{deposit_type.source}")
      end
    end
  end
end
