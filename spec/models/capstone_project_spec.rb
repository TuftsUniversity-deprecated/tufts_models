require 'spec_helper'

describe CapstoneProject do

  it_behaves_like 'rels-ext collection and ead correspond to source value', 'UA015'

  describe "validation" do
    describe "on degree" do
      it "should require a degree" do
        subject.should_not be_valid
        subject.errors[:degree].should == ["can't be blank"]
      end
    end
  end

  describe "description" do
    before do
      subject.degree = 'LLM'
      subject.description = 'student provided description'
    end

    it "should get prefixed" do
      expect(subject.tufts_pdf.description).to eq ["Submitted in partial fulfillment of the degree Masters of Law in International Law at the Fletcher School of Law and Diplomacy. Abstract: student provided description"]
    end
  end
end

