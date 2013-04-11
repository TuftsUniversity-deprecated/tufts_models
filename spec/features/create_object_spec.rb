require 'spec_helper'

feature 'Admin user creates document' do
  before do
    sign_in :admin
  end
  scenario 'with a TuftsAudio' do
    visit root_path
    click_link 'Create a new object'

    select "Audio", from: 'Type' 
  end

end
