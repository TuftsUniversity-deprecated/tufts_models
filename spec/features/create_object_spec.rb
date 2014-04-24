require 'spec_helper'

feature 'Admin user creates document' do
  before do
    sign_in :admin
    begin
      a = TuftsAudio.find('tufts:001.102.201')
      a.destroy
    rescue ActiveFedora::ObjectNotFoundError
    end
  end
  scenario 'with a TuftsAudio' do
    visit root_path
    click_link 'Create a new object'

    select "Audio", from: 'Select an object type'
    fill_in 'Pid', with: 'tufts:001.102.201'
    click_button 'Next'

    # On the upload page
    page.should have_selector('.file.btn', text: 'Upload ARCHIVAL_SOUND')
    page.should have_selector('input[type="file"].fileupload')
    page.should have_selector('div.progress.progress-striped.hidden > .bar')
    click_button 'Next'

    fill_in '*Title', with: 'My title'
    click_button 'Save'

    page.should have_selector('h1', text: 'My title')
  end

end
