require 'spec_helper'

describe 'catalog/index.html.erb' do
  before do
    @document_list = [SolrDocument.new]
    @document_list.first.stub(id: 'some_id')
    view.stub current_user: double(admin?: true),
      has_search_parameters?: true,
      render_grouped_response?: false,
      blacklight_config: CatalogController.new.blacklight_config,
      link_to_document: '',
      render_index_doc_actions: '',
      render_document_partial: ''
    Deprecation.stub(:silence)
    stub_template 'catalog/_search_sidebar.html.erb' => '',
      'catalog/_search_header.html.erb' => '',
      'catalog/_results_pagination.html.erb' => ''
    @response = double(:response, empty?: false, params: {})
    render
  end

  it 'submits to the right spot' do
    expect(rendered).to have_selector("form[action*='#{edit_batch_edits_path}']")
  end
  it 'has a box to select all documents' do
    expect(rendered).to have_selector("input#check_all[type=checkbox]")
  end
  it 'has an edit button' do
    expect(rendered).to have_selector("button#batch-edit")
  end
  it 'lets you select individual documents' do
    expect(rendered).to have_selector("input[type=checkbox][name='batch_document_ids[]'][value='#{@document_list.first.id}']")
  end
end
