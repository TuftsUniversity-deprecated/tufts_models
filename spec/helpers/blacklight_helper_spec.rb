require 'spec_helper'

describe BlacklightHelper do

  describe 'the label for the link to the object:' do

    it 'for a template object, it displays the template_title' do
      doc = SolrDocument.new('template_title_tesim' => ['My Template'])
      helper.doc_label(doc).should == 'My Template'
    end

    it 'for a non-template object, it uses normal blacklight behavior' do
      doc = SolrDocument.new('title_tesim' => ['My Title'])
      helper.should_receive(:document_show_link_field).and_return('My Title')
      helper.doc_label(doc).should == 'My Title'
    end

  end

end
