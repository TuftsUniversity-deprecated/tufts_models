require 'spec_helper'

describe TuftsDcDetailed do
  it "should have provenance" do
    subject.provenance = 'test'
    subject.provenance.should == ['test']
  end
end

