require 'spec_helper'

describe TuftsDcDetailed do
  it "should have title" do
    subject.title = 'test'
    subject.title.should == ['test']
  end
end

