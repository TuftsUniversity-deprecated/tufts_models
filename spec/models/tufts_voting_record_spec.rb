require 'spec_helper'

describe TuftsVotingRecord do

  it "should have an original_file_datastreams" do
    expect(TuftsVotingRecord.original_file_datastreams).to eq ['RECORD-XML']
  end

  describe "to_class_uri" do
    subject {TuftsVotingRecord}
    it "has sets the class_uri" do
      expect(subject.to_class_uri).to eq 'info:fedora/cm:VotingRecord'
    end
  end

end
