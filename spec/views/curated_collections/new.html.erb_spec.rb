require 'spec_helper'

describe 'curated_collections/new.html.erb' do
  it 'shows a form for creating new collections' do
    @curated_collection = CuratedCollection.new
    render
    expect(rendered).to have_selector("form#new_curated_collection input[type=text][name='curated_collection[title]']")
    expect(rendered).to have_selector("form#new_curated_collection input[type=submit]")
end
end
