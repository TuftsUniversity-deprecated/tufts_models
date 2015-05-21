require 'spec_helper'

describe BatchXmlImport do
  before do
    allow(HydraEditor).to receive(:models).and_return(['TuftsPdf'])

    class StubParser
      def initialize(xml)
      end
      def validate
        []
      end
    end
  end
  let(:metadata) do
    StringIO.new('content').tap do |stringio|
      allow(stringio).to receive_messages(local_path: "",
                    original_filename: 'foo.xml',
                    content_type: 'application/xml')
    end
  end

  after { Object.send(:remove_const, :StubParser) }

  subject { FactoryGirl.build(:batch_xml_import, parser_class: 'StubParser', metadata_file: metadata) }

  it 'has a display name' do
    expect(subject.display_name).to eq 'Xml Import'
  end

  it 'requires a metadata file' do
    subject.remove_metadata_file!
    expect(subject).to_not be_valid
  end

  it "saves uploaded_files correctly" do
    uploaded_files = [UploadedFile.new(filename: "foo.jpg", pid: "tufts:1")]
    batch = FactoryGirl.create(:batch_xml_import, uploaded_files: uploaded_files, parser_class: 'StubParser', metadata_file: metadata)
    expect(batch.reload.uploaded_files).to eq uploaded_files
  end

  it 'requires the metadata file to be valid' do
    xml = "<input><digitalObject></digitalObject></input>"
    allow(subject.metadata_file).to receive(:read) { xml }
    allow_any_instance_of(StubParser).to receive(:validate) { [double(message: 'some errors')] }
    expect(subject).to_not be_valid
    expect(subject.errors.full_messages).to include 'some errors'
  end

  it 'only checks the validity of the metadata file if it has changed' do
    expect_any_instance_of(StubParser).to receive(:validate).once { [] }
    subject.save
    expect_any_instance_of(StubParser).to receive(:validate).never
    subject.save
  end

  it 'calls read on the UploadedFile' do
    # we need it to call read here because Nokogiri won't correctly parse an
    # ActionDispatch::Http::UploadedFile
    expect(subject.metadata_file).to receive(:read).once
    subject.valid?
  end

  describe ".pids" do
    let(:m) { FactoryGirl.build(:batch_xml_import) }
    let(:file) { UploadedFile.new(filename: "foo.jpg", pid: "tufts:1") }

    it "doesn't let you assign pids directly" do
      expect { m.pids = [] }.to raise_exception(NotImplementedError)
    end

    it "gets pids from the uploaded_files" do
      expect {
        m.uploaded_files = [file]
      }.to change { m.pids }.from([]).to ["tufts:1"]
    end
  end

  describe ".missing_files" do
    it "shows missing files" do
      uploaded_files = [UploadedFile.new(filename: "hello.pdf", pid: "tufts:1")]
      m = FactoryGirl.create(:batch_xml_import, uploaded_files: uploaded_files, parser_class: 'StubParser', metadata_file: metadata)
      expect(m.parser).to receive(:filenames).and_return(['compendioussyste00brya.pdf', 'foo.bar', 'hello.pdf'])
      expect(m.missing_files).to eq ['compendioussyste00brya.pdf', 'foo.bar']
    end
  end
end
