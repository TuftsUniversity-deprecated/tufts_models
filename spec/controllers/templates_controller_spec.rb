require 'spec_helper'

describe TemplatesController, if: Tufts::Application.mira? do
  before do
    @user = FactoryGirl.create(:user)
    @admin = FactoryGirl.create(:admin)
  end

  describe 'as a non-admin user' do
    before { sign_in @user }

    it 'redirects to contributions' do
      get :index
      expect(response).to redirect_to(contributions_path)
    end

  end

  describe 'as an admin user' do
    before { sign_in @admin }

    context 'with some objects' do
      before :all do
        TuftsTemplate.destroy_all
        FactoryGirl.create(:tufts_template)
        FactoryGirl.create(:tufts_template)
        FactoryGirl.create(:tufts_pdf)
        FactoryGirl.create(:tufts_audio)
      end

      it 'returns only templates' do
        get :index
        expect(assigns[:document_list].count).to eq 2
      end
    end
  end
end
