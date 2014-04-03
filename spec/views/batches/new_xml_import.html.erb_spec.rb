require 'spec_helper'

describe "batches/new_xml_import.html.erb" do
  before do
    assign :batch, BatchXmlImport.new
    render
  end

  it 'submits to batches#create' do
    rendered.should have_selector("form[method=post][action='#{batches_path}']")
  end

  it 'displays the form to apply import via xml' do
    expect(rendered).to have_selector("input[type=hidden][name='batch[type]'][value=BatchXmlImport]")
    expect(rendered).to have_selector("input[type=file][name='batch[metadata_file]']")
  end
end
