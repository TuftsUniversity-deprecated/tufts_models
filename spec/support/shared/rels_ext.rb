require 'spec_helper'

shared_examples 'rels-ext collection and ead correspond to parent collection' do

  it 'collection and ead correspond to source' do
    ead = find_or_create_ead(subject.tufts_pdf.stored_collection_id)
    subject.tufts_pdf.ead.should == ead
    subject.tufts_pdf.collection.should == ead
  end

end

