require 'spec_helper'

describe AdvancedController do
  before do
    @user = FactoryGirl.create(:user)
    @admin = FactoryGirl.create(:admin)
  end

  context 'an admin user' do
    before { sign_in @admin }

    describe "GET index" do
      render_views

      it "doesn't use 'format' because it conflicts with rails controllers" do
        get :index
        expect(response.body).to have_selector('input[name=format_attr]')
      end
    end
  end
end
