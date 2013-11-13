require 'spec_helper'

describe HonorsThesis do
  before :all do
    create_ead('UA005')
  end

  it_behaves_like 'rels-ext collection and ead correspond to source value', 'UA005'

  describe "validation" do
    describe "on department" do
      it "should require a department" do
        subject.should_not be_valid
        subject.errors[:department].should == ["can't be blank"]
      end
    end
  end

  describe "setting creatordept" do
    describe "when the supplied value is a member of the list" do
      before do
        subject.department = 'Dept. of German, Russian, and Asian Languages and Literature'
      end
      it "should be the corresponding code" do
        subject.tufts_pdf.creatordept.should == 'UA005.014'
      end
    end
    describe "when the supplied value is not a member of the list" do
      before do
        subject.department = 'German'
      end
      it "should be marked as NEEDS FIXING" do
        subject.tufts_pdf.creatordept.should == 'NEEDS FIXING'
      end
    end
  end
end
