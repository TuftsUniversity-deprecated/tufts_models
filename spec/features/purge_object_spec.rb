require 'spec_helper'

feature 'Admin user purges document', if: Tufts::Application.mira? do
  before do
    TuftsAudio.where(title: "Very unique title").destroy_all
    @audio = TuftsAudio.new(title: 'Very unique title', description: 'eh?', creator: 'Fred', displays: ['dl'])
    @audio.save!
    sign_in :admin
  end
  scenario 'with a TuftsAudio' do
    visit catalog_path(@audio)
    click_link 'Purge'
    page.should have_selector('div.alert', text: '"Very unique title" has been purged')

    fill_in 'q', with: 'Very unique title'
    click_button 'search'
    page.should have_text('No entries found')
  end

end


