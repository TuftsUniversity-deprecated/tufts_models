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
      response.should redirect_to(contributions_path)
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

    describe 'GET show JSON' do
      it 'returns JSON data needed by the view template (jquery file uploader template)' do
        record = FactoryGirl.create(:tufts_pdf, user: @admin)
        get :show, id: record.pid, format: :json, json_format: 'jquery-file-uploader'

        expect(response).to be_successful
        json = JSON.parse(response.body)['files'].first
        expect(json['pid']).to eq record.pid
        expect(json['name']).to eq record.title
        record.delete
      end
    end

    context 'viewing templates' do
      before { @excluded = FactoryGirl.create(:tufts_template) }
      after { @excluded.destroy }

      it 'filters from index' do
        get :index
        pid_list = assigns[:document_list].map {|doc| doc.id}
        expect(pid_list).not_to include(@excluded.pid)
      end
    end

  end

end
