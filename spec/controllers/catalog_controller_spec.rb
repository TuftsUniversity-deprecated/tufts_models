require 'spec_helper'

describe CatalogController do
  before do
    @user = FactoryGirl.create(:user)
    @admin = FactoryGirl.create(:admin)
  end

  context 'a non-admin user' do
    before { sign_in @user }

    it 'denied access to catalog' do
      get :index
      response.should redirect_to(contribute_path)
    end

    it 'denied access to someone elses document' do
      not_my_doc = FactoryGirl.create(:tufts_pdf, user: @admin)
      get :show, id: not_my_doc.pid
      response.should redirect_to(root_path)
    end

    it 'has access to my own document' do
      my_doc = FactoryGirl.create(:tufts_pdf, user: @user)
      get :show, id: my_doc.pid
      response.should be_successful
      response.should render_template(:show)
    end
  end

  context 'an admin user' do
    before { sign_in @admin }

    it "should have #facet" do
      get :facet, id: 'names_sim'
      response.should be_successful
    end

    it 'gets catalog' do
      get :index
      response.should be_successful
      response.should render_template(:index)
    end

    it 'can view someone elses document' do
      not_my_doc = FactoryGirl.create(:tufts_pdf, user: @user)
      get :show, id: not_my_doc.pid
      response.should be_successful
      response.should render_template(:show)
    end
  end

end
