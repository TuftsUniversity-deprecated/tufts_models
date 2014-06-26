require 'spec_helper'

describe 'display curated collection', if: Tufts::Application.til? do
  let(:user) { FactoryGirl.create(:user) }
  let(:image1) { FactoryGirl.create(:image, title: 'First') }
  let(:image2) { FactoryGirl.create(:image, title: 'Second') }
  let(:image3) { FactoryGirl.create(:image, title: 'Third') }
  let(:collection) { FactoryGirl.create(:curated_collection, title: "A very fine collection", user: user) }

  before do
    collection.members << image2
    collection.members << image3
    collection.members << image1
    collection.save!
  end

  it "should draw the collection in order" do
    sign_in user
    visit curated_collection_path(collection)

    expect(page).to have_content 'A very fine collection'
    expect(page).to have_selector('ol li:nth-child(1) a', text: 'Second')
    expect(page).to have_selector('ol li:nth-child(2) a', text: 'Third')
    expect(page).to have_selector('ol li:nth-child(3) a', text: 'First')
  end
end
