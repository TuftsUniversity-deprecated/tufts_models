require 'spec_helper'

describe TuftsRCR do
  it "should have an original_file_datastreams" do
    expect(TuftsRCR.original_file_datastreams).to eq ['RCR-CONTENT']
  end
 
  describe "to_class_uri" do
    subject {TuftsRCR}
    it "has sets the class_uri" do
      expect(subject.to_class_uri).to eq 'info:fedora/cm:Text.RCR'
    end
  end
end
