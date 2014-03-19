require 'spec_helper'

describe 'records/edit.html.erb' do

  describe 'the page title' do
    before { stub_template 'records/_form' => '' }

    it "displays the object's title" do
      record = double(title: 'My Document', has_thumbnail?: false, id: 'pid:123')
      assign :record, record
      render
      expect(rendered).to have_content('Edit My Document')
    end

    it "displays the template_title if the object is a template" do
      record = double(template_title: 'My Template', title: 'My Document', has_thumbnail?: false, id: 'pid:123')
      assign :record, record
      render
      expect(rendered).to have_content('Edit My Template')
    end

  end
end
