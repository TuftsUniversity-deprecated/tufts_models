require 'spec_helper'

shared_examples 'rels-ext collection and ead correspond to source value' do |source|
  let(:collection) { create_ead(source) }

  it 'collection and ead correspond to source' do
    subject.tufts_pdf.ead == collection
    subject.tufts_pdf.collection == collection
  end

end

