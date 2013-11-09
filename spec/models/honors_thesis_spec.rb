require 'spec_helper'

describe HonorsThesis do
  describe "validation" do
    describe "on department" do
      it "should require a department" do
        subject.should_not be_valid
        subject.errors[:department].should == ["can't be blank"]
      end
    end
  end

end
