require 'spec_helper'

describe CuratedCollection do

  subject { CuratedCollection.new title: 'some title' }
  describe "to_class_uri" do
    it "sets the displays" do
      expect(subject.displays).to eq ['tdil']
    end

    it "allows tdil as a display" do
      expect(subject.save).to be_truthy
    end
  end
end
