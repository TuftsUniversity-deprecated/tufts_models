require 'spec_helper'

describe UploadedFile do
  describe "batch=" do
    let(:upload) { described_class.new }
    let(:dummy) { double(validate: []) }

    let(:metadata) do
      StringIO.new('content').tap do |stringio|
        allow(stringio).to receive_messages(local_path: "",
                      original_filename: 'foo.xml',
                      content_type: 'application/xml')
      end
    end
    before do
      allow_any_instance_of(BatchXmlImport).to receive(:parser) { dummy }
    end
    let(:import) { FactoryGirl.create(:batch_xml_import, metadata_file: metadata) }


    it "belongs_to a BatchXMLImport" do
      upload.batch = import
      upload.save!
      expect(import.reload.uploaded_files).to eq [upload]
    end
  end
end
