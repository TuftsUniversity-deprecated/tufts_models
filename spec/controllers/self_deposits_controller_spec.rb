require 'spec_helper'
require "cancan/matchers"

describe SelfDepositsController do
  before do
    #@routes = HydraEditor::Engine.routes
    @routes = Tufts::Application.routes
  end

  describe "| A contributor" do
    before do
      @user = FactoryGirl.create(:admin)
      sign_in @user
    end

    describe "who goes to the new page" do
      before :all do
        @test_pid = "TestTest:4321.1234"
      end

      it "should be allowed to create a new deposit item" do
        post :create, :type=>'TuftsSelfDeposit', :tufts_self_deposit=>{:title=>"My self-deposit"}
      end

      it "should be recorded as the contributor" do
        post :create, :type=>'TuftsSelfDeposit', :tufts_self_deposit=>{:title=>"My self-deposit"}
        assigns[:self_deposit].creator.should include @user.to_s
      end

    end
  end
end
