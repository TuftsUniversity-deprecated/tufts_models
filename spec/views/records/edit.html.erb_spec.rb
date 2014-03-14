require 'spec_helper'

describe 'records/edit.html.erb' do

  describe 'the page title' do
    before { stub_template 'records/_form' => '' }

    it "displays the object's title" do
      record = double(title: 'My Document', has_thumbnail?: false, id: 'pid:123', to_solr: {})
      assign :record, record
      render
      expect(rendered).to have_content('Edit My Document')
    end

    it "displays the template_name if the object is a template" do
      record = double(template_name: 'My Template', title: 'My Document', has_thumbnail?: false, id: 'pid:123', to_solr: {})
      assign :record, record
      render
      expect(rendered).to have_content('Edit My Template')
    end
  end


  describe 'Link to template index' do
    before { stub_template 'records/_form' => '' }

    it 'is displayed if the object is a template' do
      record = double(template_name: 'My Template', title: 'My Document', has_thumbnail?: false, id: 'pid:123', to_solr: {})
      expect(record).to receive(:is_a?).with(TuftsTemplate) { true }
      assign :record, record
      render
      expect(rendered).to have_link('Index of Templates', href: templates_path)
    end

    it 'is not displayed if the object is not a template' do
      record = double(title: 'My Document', has_thumbnail?: false, id: 'pid:123', to_solr: {})
      assign :record, record
      render
      expect(rendered).to_not have_link('Index of Templates', href: templates_path)
    end
  end

end
