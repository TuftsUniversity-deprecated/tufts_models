require 'spec_helper'

describe DerivativeAttachmentService do
  let(:object) { TuftsImage.new }
  let(:dsid) { 'Advanced.jpg' }
  let(:mime_type) { 'image/jpeg' }
  let(:service) { described_class.attach(object, dsid, url, mime_type) }
  let(:url) { 'http://bucket01.lib.tufts.edu/data01/tufts/central/dca/MISS/advanced_jpg/MISS.ISS.IPPI.advanced.jpg' }

  describe ".attach" do
    let(:datastream) { object.datastreams[dsid] }
    before do
      datastream.checksum = '99999'
    end
    it "clears the checksum" do
      expect { service }.to change { datastream.checksum }.to(nil)
      expect(datastream.dsLocation).to eq url
    end
  end
end
