require 'spec_helper'

describe FacultyScholarship do
  it "should record 'other_authors' as creators" do
    subject.creator = 'Dave'
    subject.other_authors = 'Jane'
    subject.tufts_pdf.creator.should == ['Dave', 'Jane']
  end
end
