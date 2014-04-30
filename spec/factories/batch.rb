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

  factory :batch_revert do
    type 'BatchRevert'
    association :creator, factory: :admin
    created_at 2.minutes.ago
    pids ["tufts:1", "tufts:2"]
  end

  factory :batch_template_import do
    type 'BatchTemplateImport'
    association :creator, factory: :admin
    template_id { FactoryGirl.create(:template_with_required_attributes).id }
    record_type 'TuftsPdf'
  end

  factory :batch_xml_import do
    type 'BatchXmlImport'
    association :creator, factory: :admin
    metadata_file { Rack::Test::UploadedFile.new(File.join(Rails.root, 'spec', 'fixtures', 'MIRABatchUpload_valid.xml')) }
  end

end
