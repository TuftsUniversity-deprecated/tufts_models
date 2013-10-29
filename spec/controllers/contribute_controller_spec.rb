require 'spec_helper'

describe ContributeController do
  before do
    @user = FactoryGirl.create(:admin)
    sign_in @user
  end

  describe "GET 'home'" do
    it "returns http success" do
      get 'home'
      response.should be_success
    end
  end

  describe "GET 'license'" do
    it "returns http success" do
      get 'license'
      response.should be_success
    end
  end

  describe "GET 'new'" do
    it "redirects to contribute home when no deposit type specified" do
      get 'new'
      response.should redirect_to contribute_path
    end
  end

  describe "GET 'create'" do
    it "redirects to contribute new when no deposit type is specified" do
      get 'create'
      response.should redirect_to new_contribute_path
    end
  end

end
