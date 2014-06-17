require 'spec_helper'

describe FacultyScholarship do

  it_behaves_like 'rels-ext collection and ead are the same'

  it "should record 'other_authors' as creators" do
    subject.creator = 'Dave'
    subject.other_authors = 'Jane'
    subject.tufts_pdf.creator.should == ['Dave', 'Jane']
  end

end
