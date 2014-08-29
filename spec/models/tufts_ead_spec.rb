require 'spec_helper'

describe TuftsEAD do

  it "should have an original_file_datastreams" do
    expect(TuftsEAD.original_file_datastreams).to eq ['Archival.xml']
  end

  describe "to_class_uri" do
    subject {TuftsEAD}
    it "has sets the class_uri" do
      expect(subject.to_class_uri).to eq 'info:fedora/cm:Text.EAD'
    end
  end

end
