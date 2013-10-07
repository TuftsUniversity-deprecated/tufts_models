require 'spec_helper'
require "cancan/matchers"

describe SelfDepositsController do
  before do
    #@routes = HydraEditor::Engine.routes
    @routes = Tufts::Application.routes
  end

  describe "a contributor" do
    before do
      sign_in FactoryGirl.create(:user)
    end

    describe "who goes to the new page" do
      before :all do

      end

      it "should be allowed" do
        post :create, :type=>'TuftsSelfDeposit', :tufts_self_deposit=>{:title=>"My self-deposit"}

      end

    end
  end
end
