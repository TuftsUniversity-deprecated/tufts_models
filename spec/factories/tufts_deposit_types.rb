# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :tufts_deposit_type do
    display_name "MyString"
    deposit_agreement "MyText"
  end
end
