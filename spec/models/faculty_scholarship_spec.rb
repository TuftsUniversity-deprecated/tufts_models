require 'spec_helper'

describe FacultyScholarship do
  before :all do
    create_ead('PB')
  end

  it_behaves_like 'rels-ext collection and ead correspond to source value', 'PB'

  it "should record 'other_authors' as creators" do
    subject.creator = 'Dave'
    subject.other_authors = 'Jane'
    subject.tufts_pdf.creator.should == ['Dave', 'Jane']
  end

end
