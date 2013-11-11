require 'spec_helper'

describe CapstoneProject do
  describe "validation" do
    describe "on degree" do
      it "should require a degree" do
        subject.should_not be_valid
        subject.errors[:degree].should == ["can't be blank"]
      end
    end
  end

end

