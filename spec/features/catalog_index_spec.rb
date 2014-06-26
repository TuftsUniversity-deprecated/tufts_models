require 'spec_helper'

feature 'View catalog index', if: Tufts::Application.mira? do
  before do
    ActiveFedora::Base.delete_all
    sign_in :admin
  end

  let!(:reviewed_pdf) {
    pdf = FactoryGirl.create(:tufts_pdf) 
    pdf.reviewed
    pdf.batch_id = ['1']
    pdf.save!
    pdf
  }

  scenario 'easily see which objects have been marked as reviewed' do
    visit root_path
    click_button 'Search'
    expect(page).to have_selector('.document input[type=checkbox][name=reviewed]', count: 1)
  end

end
