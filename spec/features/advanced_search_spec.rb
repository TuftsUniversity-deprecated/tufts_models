require 'spec_helper'

feature 'Advanced Search' do

  before do
    ActiveFedora::Base.delete_all

    @fiction = FactoryGirl.create(:tufts_pdf, title: 'Space Detectives', genre: ['science fiction', 'fiction'])
    @history = FactoryGirl.create(:tufts_pdf, title: 'Scientific Discoveries', genre: ['history', 'science'])

    sign_in :admin
  end

  after do
    @fiction.delete
    @history.delete
  end

  scenario 'search with AND' do
    visit root_path
    click_link 'Advanced Search'
    fill_in :genre, with: 'science AND history'
    click_button 'advanced_search'

    page.should     have_link('Scientific Discoveries', href: catalog_path(@history))
    page.should_not have_link('Space Detectives', href: catalog_path(@fiction))
  end

  scenario 'search with OR' do
    visit root_path
    click_link 'Advanced Search'
    fill_in :genre, with: 'science OR history'
    click_button 'advanced_search'

    page.should have_link('Scientific Discoveries', href: catalog_path(@history))
    page.should have_link('Space Detectives', href: catalog_path(@fiction))
  end

  scenario 'negative search' do
    visit root_path
    click_link 'Advanced Search'
    fill_in :genre, with: 'science -fiction'
    click_button 'advanced_search'

    page.should     have_link('Scientific Discoveries', href: catalog_path(@history))
    page.should_not have_link('Space Detectives', href: catalog_path(@fiction))
  end

  scenario "templates don't appear in facets" do
    FactoryGirl.create(:tufts_template)
    visit root_path
    click_link 'Advanced Search'
    within('#facets .blacklight-object_type_sim') do
      expect(page).to have_selector('li', count: 1)
      expect(page).to have_selector('li .facet_select', text: "Text")
      expect(page).to have_selector('li .facet-count', text: 2)
      expect(page).to_not have_content('Template')
    end
  end

  scenario "purged objects don't appear in facets" do
    @history.purge!
    visit root_path
    click_link 'Advanced Search'
    within('#facets .blacklight-object_type_sim') do
      expect(page).to have_selector('li', count: 1)
      expect(page).to have_selector('li .facet_select', text: "Text")
      expect(page).to have_selector('li .facet-count', text: 1)
    end
  end

end
