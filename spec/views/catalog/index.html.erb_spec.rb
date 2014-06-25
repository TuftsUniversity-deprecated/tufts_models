require 'spec_helper'

describe 'catalog/index.html.erb' do
  before do
    @document_list = [SolrDocument.new(id: 'some_id')]
    {current_user: double(admin?: true),
      has_search_parameters?: false,
      render_grouped_response?: false,
      blacklight_config: CatalogController.new.blacklight_config,
      render_index_doc_actions: '',
      search_session: {},
      current_search_session: nil
    }.each do |m, result|
      allow(view).to receive(m) { result }
    end
    allow(Deprecation).to receive(:silence)
    stub_template 'catalog/_search_sidebar.html.erb' => '',
      'catalog/_search_header.html.erb' => '',
      'catalog/_results_pagination.html.erb' => ''
    assign :response, double(:response, empty?: false, params: {}, total: 0, start: 0, limit_value: 10)
    @curated_collection_to_create = CuratedCollection.new
    @curated_collections = []
  end

  context 'viewing the main page' do
    it "doesn't show the form for creating new collections" do
      render
      expect(rendered).to_not have_selector("form#new_curated_collection input[type=text][name='curated_collection[title]']")
      expect(rendered).to_not have_selector("form#new_curated_collection input[type=submit]")
    end
  end

  context 'viewing search results' do
    before do
      allow(view).to receive(:has_search_parameters?) { true }
    end

    describe 'checkboxes' do
      before do
        render
      end
      it 'has a box to select all documents' do
        expect(rendered).to have_selector("input#check_all[type=checkbox]")
      end
      it 'lets you select individual documents' do
        expect(rendered).to have_selector("input.batch_document_selector[type=checkbox][name='batch[pids][]'][value='#{@document_list.first.id}']")
      end
    end

    describe 'batch operations' do
      it 'submits to batch#create' do
        render
        expect(rendered).to have_selector("form[method=post][action='#{batches_path}']")
      end

      it 'sends the form page as a hidden field' do
        render
        expect(rendered).to have_selector("input[type=hidden][name='batch_form_page'][value='1']")
      end

      it 'displays the button to apply a template' do
        render
        expect(rendered).to have_selector("button[type=submit][name='batch[type]'][value=BatchTemplateUpdate][data-behavior=batch-create]")
      end

      it 'displays the button to publish' do
        render
        expect(rendered).to have_selector("button[type=submit][name='batch[type]'][value=BatchPublish][data-behavior=batch-create]")
      end

      it 'has the div needed by javascript to display the number of documents that are currently selected' do
        render
        expect(rendered).to have_selector("#selected_documents_count")
      end
    end

    describe 'with a document that is an image' do
      before do
        @document_list = [SolrDocument.new(id: 'id2', has_model_ssim: ['fedora/cm:Image.4DS'])]
        render
      end
      it 'displays thumbnails' do
        src = download_path(@document_list.first.id, datastream_id: 'Thumbnail.png')
        expect(rendered).to have_selector("#documents .document-thumbnail img[src='#{src}']")
      end
    end

    describe 'showing the gallery view' do
      before do
        @document_list = [SolrDocument.new(id: 'id2', has_model_ssim: ['fedora/cm:Image.4DS'])]
        assign :response, double(:response, empty?: false, params: {view: 'gallery'}, total: 0, start: 0, limit_value: 10)
        assigns[:request].params[:view] = 'gallery'
        allow(view).to receive(:params) { assigns[:request].params }
      end

      it 'displays thumbnails' do
        render
        src = download_path(@document_list.first.id, datastream_id: 'Thumbnail.png')
        expect(rendered).to have_selector("#documents.gallery .document .thumbnail img[src='#{src}']")
      end
    end

    describe "showing collections", if: Tufts::Application.til? do

      it 'shows a form for creating new collections' do
        render
        expect(rendered).to have_selector("form#new_curated_collection input[type=text][name='curated_collection[title]']")
        expect(rendered).to have_selector("form#new_curated_collection input[type=submit]")
      end

      it 'displays the list of curated collections' do
        @curated_collections = [CuratedCollection.create(title: 'foo')]
        render
        expect(rendered).to have_selector(".curated-collection-list li[data-collection-id='#{@curated_collections.first.pid}']")
      end
    end
  end
end
