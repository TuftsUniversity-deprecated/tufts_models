require 'spec_helper'

describe DcaAdmin do
  it "should have a published date" do
    time = DateTime.parse('2013-03-22T12:33:00Z')
    subject.published_at = time
    subject.published_at.should == [time]
  end

  it "should have an edited date" do
    time = DateTime.parse('2013-03-22T12:33:00Z')
    subject.edited_at = time
    subject.edited_at.should == [time]
  end
end
