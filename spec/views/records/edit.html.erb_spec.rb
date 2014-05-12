require 'spec_helper'

describe 'records/edit.html.erb' do

  describe 'the page title' do
    before { stub_template 'records/_form.html.erb' => '' }

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
    before { stub_template 'records/_form.html.erb' => '' }

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

  describe 'relationship fields' do
    let!(:pdf) { FactoryGirl.create(:tufts_pdf) }
    after { pdf.destroy }

    before do
      assign :record, pdf
      render
    end

    it 'contains selectors needed for the javascript' do
      expect(rendered).to have_selector('#additional_relationship_attributes_clone')
      expect(rendered).to have_selector('#additional_relationship_attributes_elements')
      expect(rendered).to have_selector('#additional_relationship_attributes_clone button.adder')
    end
  end

end
