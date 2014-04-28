require 'spec_helper'

feature 'View catalog index' do
  before do
    ActiveFedora::Base.delete_all
    sign_in :admin
  end

  let!(:reviewed_pdf) {
    pdf = FactoryGirl.create(:tufts_pdf) 
    pdf.reviewed
    pdf.save!
    pdf
  }

  scenario 'easily see which objects have been marked as reviewed' do
    visit root_path
    click_button 'Search'
    expect(page).to have_selector('.document dt.blacklight-qrstatus_tesim', count: 1)
  end

end
