require 'spec_helper'

describe BlacklightHelper do

  before do
    config = CatalogController.new.blacklight_config
    helper.stub(:blacklight_config).and_return(config)
  end

  describe '#document_show_link_field' do
    it 'for a template object, it displays the template_name' do
      doc = SolrDocument.new('template_name_tesim' => ['My Template'])
      helper.document_show_link_field(doc).should == :template_name_tesim
    end

    it 'for a non-template object, it falls back to normal blacklight behavior' do
      doc = SolrDocument.new('title_tesim' => ['My Title'])
      helper.document_show_link_field(doc).should == :title_tesim
    end

  end

  describe '#document_heading' do
    it 'for a template object, it displays the temlate_name' do
      doc = SolrDocument.new('template_name_tesim' => ['My Template'])
      helper.document_heading(doc).should == ['My Template']
    end

    it 'for a non-template object, it falls back to normal blacklight behavior' do
      doc = SolrDocument.new('title_tesim' => ['My Title'])
      helper.document_heading(doc).should == ['My Title']
    end
  end

end
