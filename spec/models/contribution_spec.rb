require 'spec_helper'

describe Contribution do
  describe "validation" do
    describe "on title" do
      it "shouldn't permit a title longer than 250 chars" do
        subject.title = "Small batch street art jean shorts umami Terry Richardson chia. Readymade stumptown kogi Cosby sweater hashtag scenester. Semiotics beard fap High Life. Quinoa mustache salvia deep v, Shoreditch Tonx gluten-free forage banh mi Truffaut selfies Odd Future"
        subject.should_not be_valid
        subject.errors[:title].should == ['is too long (maximum is 250 characters)']
      end
      it "should require a title" do
        subject.should_not be_valid
        subject.errors[:title].should == ["can't be blank"]
      end
    end
    it "shouldn't permit an abstract longer than 2000 chars" do
        subject.abstract = "Small batch street art jean shorts umami Terry Richardson chia. Readymade stumptown kogi Cosby sweater hashtag scenester. Semiotics beard fap High Life. Quinoa mustache salvia deep v, Shoreditch Tonx gluten-free forage banh mi Truffaut selfies Odd Future" * 8
        subject.should_not be_valid
        subject.errors[:abstract].should == ['is too long (maximum is 2000 characters)']
    end
    it "should require an abstract" do
        subject.should_not be_valid
        subject.errors[:abstract].should == ["can't be blank"]
    end
    it "should require a creator" do
        subject.should_not be_valid
        subject.errors[:creator].should == ["can't be blank"]
    end
    it "should require an attachment" do
        subject.should_not be_valid
        subject.errors[:attachment].should == ["can't be blank"]
    end
  end

  it "should have 'subject'" do
      subject.subject = 'test subject'
      subject.subject.should == 'test subject'
  end
end
