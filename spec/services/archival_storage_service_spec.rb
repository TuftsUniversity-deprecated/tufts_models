require 'spec_helper'

describe ArchivalStorageService do
  let(:object) { FactoryGirl.create(:tufts_pdf) }
  let(:dsid) { TuftsPdf.original_file_datastreams.first }
  let(:file) { Rack::Test::UploadedFile.new(File.join('spec', 'fixtures', 'hello.pdf'), 'application/pdf') }
  let(:service) { described_class.new(object, dsid, file) }
  let(:datastream) { object.datastreams[dsid] }
  let(:pid) { PidUtils.stripped_pid(object.pid) }

  it "should store the file" do
    expect { service.run }.to change { datastream.dsLocation }.from(nil).
      to("http://bucket01.lib.tufts.edu/data01/tufts/sas/archival_pdf/#{pid}.archival.pdf")
  end
end
