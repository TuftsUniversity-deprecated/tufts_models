require 'spec_helper'

feature 'View unpublished documents' do
  before do
    TuftsAudio.where(title: "Very unique title").destroy_all
    @production = TuftsAudio.new(title: 'Very unique title', description: 'eh?', creator: 'Fred')
    @production.push_to_production!

    @not_production = TuftsAudio.new(title: 'Very unique title', description: 'eh?', creator: 'Fred')
    @not_production.save!

  end
  scenario 'with a TuftsAudio' do
    visit root_path
    click_link 'Unpublished objects'

    fill_in 'q',      with: 'Very unique title'
    click_button 'Search'

    page.should have_link('Very unique title', href: catalog_path(@not_production) )
    page.should_not have_link('Very unique title', href: catalog_path(@production) )
  end

end


