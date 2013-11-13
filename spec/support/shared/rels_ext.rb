require 'spec_helper'

shared_examples 'rels-ext collection and ead correspond to source value' do |source|
  let(:collection_id) { "tufts:UA069.001.DO.#{source}" }
  before do
    unless ActiveFedora::Base.exists? collection_id
      create_ead(source)
    end
    subject.tufts_pdf.collection_id = collection_id
  end

  it 'collection and ead correspond to source' do
    expected_collection = /^.*isMemberOf rdf:resource="info:fedora\/tufts:UA069\.001\.DO\.#{source}.*$/
    expected_ead = /^.*hasDescription rdf:resource="info:fedora\/tufts:UA069\.001\.DO\.#{source}.*$/

    rels_ext = subject.tufts_pdf.rels_ext.content
    rels_ext.should =~ expected_collection
    rels_ext.should =~ expected_ead
  end

end

