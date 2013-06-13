require 'spec_helper'


describe Audit do
  it "should store properties" do
    subject.who = 'Sara'
    subject.what = 'Updated metadata'
    subject.when = DateTime.now

    subject.who.should == ['Sara']
    subject.what.should == ['Updated metadata']
    subject.when.first.should be_kind_of DateTime
  end
end
