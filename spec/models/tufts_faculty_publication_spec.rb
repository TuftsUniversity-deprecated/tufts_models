require 'spec_helper'

describe TuftsFacultyPublication do

  describe "to_class_uri" do
    subject {TuftsFacultyPublication}
    it "has sets the class_uri" do
      expect(subject.to_class_uri).to eq 'info:fedora/cm:Text.FacPub'
    end
  end

  it "should have an original_file_datastream" do
    expect(TuftsFacultyPublication.original_file_datastreams).to eq ["Archival.pdf"]
  end

end
