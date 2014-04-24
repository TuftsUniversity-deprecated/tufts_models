require 'spec_helper'

describe "batches/new_template_import.html.erb" do
  before do
    @templates = [
      FactoryGirl.create(:tufts_template),
      FactoryGirl.create(:tufts_template)
    ]
    assign :batch, BatchTemplateImport.new
    render
  end

  it 'submits to batches#create' do
    rendered.should have_selector("form[method=post][action='#{batches_path}']")
  end

  it 'displays the form to apply a template' do
    expect(rendered).to have_selector("input[type=hidden][name='batch[type]'][value=BatchTemplateImport]")
    expect(rendered).to have_selector("select[name='batch[template_id]']")
    @templates.each do |t|
      rendered.should have_selector("option[value='#{t.id}']")
    end
    expect(rendered).to have_selector("select[name='batch[record_type]']")
  end
end
