require 'spec_helper'

describe 'advanced/_facet_limit.html.erb' do
  before do
    allow(view).to receive(:display_facet) { double(items: @seven_facet_values) }
    allow(view).to receive(:solr_field) { 'subject_sim' }
    allow(view).to receive(:facet_limit_for) { 2 }
    allow(Blacklight::Solr::FacetPaginator).to receive(:new) { double(items: [], has_next?: true) }
  end

  describe 'facet drilldown' do
    before do
      render
    end

    context "with more than 7 subjects" do
      it 'has a more link' do
        expect(rendered).to have_selector("a.more_facets_link[href='/advanced/facet?id=subject_sim']")
      end
    end
  end
end
