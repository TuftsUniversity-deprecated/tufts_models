require 'factory_girl'

FactoryGirl.define do
  factory :batch_template_update do
    association :creator, factory: :admin
    template_id { FactoryGirl.create(:tufts_template).id }
    pids ["tufts:1", "tufts:2"]
  end
end
