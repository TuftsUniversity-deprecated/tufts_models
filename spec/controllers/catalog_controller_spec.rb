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

    it 'fix me' do
      pending
    end
#    describe 'GET show JSON' do
#      it 'returns a json document' do
#        record = FactoryGirl.create(:tufts_pdf, user: @admin)
#        get :show, id: record.pid, format: :json
#
#        expect(response).to be_successful
#
#        puts '--------------'
#        pp JSON.parse(response.body)
#
#        json = JSON.parse(response.body)['files'].first
#        expect(json['id']).to eq record.pid
#        expect(json['name']).to eq record.title
#        expect(json['url']).to eq catalog_path(record.pid)
#
#        record.delete
#      end
#
#      it 'request a non-existent record returns not found' do
#        pid = 'fake_pid:123'
#        ActiveFedora::Base.delete(pid) if ActiveFedora::Base.exists?(pid)
#        get :show, id: pid, format: :json
#        expect(response).to be_not_found
#      end
#    end

    context 'viewing templates' do
      before { @excluded = FactoryGirl.create(:tufts_template) }
      after { @excluded.destroy }

      it 'filters from index' do
        get :index
        pid_list = assigns[:document_list].map {|doc| doc.id}
        expect(pid_list).not_to include(@excluded.pid)
      end

      pending it 'filters from show' do
      # 3/27/2014 Need to determine if this is really the desired functionality
        get :show, id: @excluded.pid
        expect(response.status).to eq(404)
        expect(response).to redirect_to(app_root)
      end
    end

  end

end
