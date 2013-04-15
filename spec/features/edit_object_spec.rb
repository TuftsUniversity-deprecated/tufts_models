require 'spec_helper'

feature 'Admin user edits document' do
  before do
    @audio = TuftsAudio.new(title: 'Test title', description: 'eh?', creator: 'Fred')
    @audio.save!
    sign_in :admin
  end
  scenario 'with a TuftsAudio' do
    visit catalog_path(@audio)
    click_link 'Edit'

    fill_in '*Title',      with: 'My title'
    fill_in 'Description', with: 'My desc'
    fill_in 'Creator',     with: 'Gillian'
    click_button 'Save'

    page.should have_selector('h1', text: 'My title')
  end

end

