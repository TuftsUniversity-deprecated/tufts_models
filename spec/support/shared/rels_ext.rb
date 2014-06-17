require 'spec_helper'

shared_examples 'rels-ext collection and ead are the same' do

  it 'collection and ead are the same' do
    ead = find_or_create_ead(subject.tufts_pdf.stored_collection_id)
    expect(subject.tufts_pdf.ead).to eq subject.tufts_pdf.collection
  end

end

