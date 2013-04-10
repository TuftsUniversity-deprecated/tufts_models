require 'spec_helper'

feature 'Admin user creates document' do
  before do
    sign_in :admin
  end
  scenario 'with a TuftsAudio' do
    pending
    visit root_path
    click_link 'Add Object'

    select "Audio", from: 'Type' 
  end

end
