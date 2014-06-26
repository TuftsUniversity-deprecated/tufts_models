require 'spec_helper'

feature 'Search by batch ID', if: Tufts::Application.mira? do
  before do
    ActiveFedora::Base.delete_all

    @image = TuftsImage.create!(title: 'Img 1', displays: ['dl'], batch_id: ['2'])
    @pdf = TuftsPdf.create!(title: 'PDF 1', displays: ['dl'], batch_id: ['27'])
    @audio = TuftsAudio.create!(title: 'Aud 1', displays: ['dl'], batch_id: ['32'])

    sign_in :admin
  end

  after do
    @image.delete
    @pdf.delete
    @audio.delete
  end

  scenario 'search for batch id of 2' do
    visit root_path
    select 'Batch', from: :search_field
    fill_in :q, with: '2'
    click_button 'Search'

    page.should     have_link('Img 1', href: catalog_path(@image))
    page.should_not have_link('PDF 1', href: catalog_path(@pdf))
    page.should_not have_link('Aud 1', href: catalog_path(@audio))
  end

end

