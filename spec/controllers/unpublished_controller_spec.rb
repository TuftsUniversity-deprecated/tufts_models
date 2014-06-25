require 'spec_helper'

describe UnpublishedController, if: Tufts::Application.mira? do
  before do
    sign_in FactoryGirl.create(:admin)
  end
  it "should have #facet" do
    get :facet, id: 'names_sim'
    response.should be_successful
  end

end

