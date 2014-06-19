require 'spec_helper'

describe 'advanced/index.html.erb' do
  before do
    view.lookup_context.prefixes << 'catalog'
    allow(view).to receive(:blacklight_config) { CatalogController.new.blacklight_config }
    allow(view).to receive(:advanced_search_context) { {"f"=>{"subject_sim"=>["African Drumming"]}}.with_indifferent_access }
    stub_template 'advanced/_search_sidebar.html.erb' => ''
    stub_template 'advanced/_advanced_search_facets.html.erb' => ''
  end

  describe 'search form' do
    before do
      render
    end

    context "with a facet selected" do
      it "keeps the selected facet info in the form" do
        expect(rendered).to have_selector("input[type=hidden][name='f[subject_sim][]'][value='African Drumming']")
      end
    end
  end
end
