require 'factory_girl'

FactoryGirl.define do
  factory :batch_template_update do
    type 'BatchTemplateUpdate'
    association :creator, factory: :admin
    template_id { FactoryGirl.create(:tufts_template).id }
    created_at 1.minute.ago
    pids ["tufts:1", "tufts:2"]
  end

  factory :batch_publish do
    type 'BatchPublish'
    association :creator, factory: :admin
    created_at 2.minutes.ago
    pids ["tufts:1", "tufts:2"]
  end

  factory :batch_purge do
    type 'BatchPurge'
    association :creator, factory: :admin
    created_at 3.minutes.ago
    pids ["tufts:1", "tufts:2"]
  end
end
