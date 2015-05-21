require 'spec_helper'

describe UploadedFile do
  describe "batch=" do
    let(:upload) { described_class.new }
    let(:dummy) { double(validate: []) }
    let(:import) { FactoryGirl.create(:batch_xml_import, parser: dummy) }

    it "belongs_to a BatchXMLImport" do
      upload.batch = import
      upload.save!
      expect(import.reload.uploaded_files).to eq [upload]
    end
  end
end
