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
      end

      it "should be allowed to create a new deposit item" do
        post :create, :type=>'TuftsSelfDeposit', :tufts_self_deposit=>{:title=>"My self-deposit"}
      end
    end

    describe "who creates a new deposit" do

      it "should be recorded as the contributor" do
        post :create, :type=>'TuftsSelfDeposit', :tufts_self_deposit=>{:title=>"My self-deposit"}
        assigns[:self_deposit].creator.should include @user.to_s
      end

      it "should list accrual policy as self deposit" do
        post :create, :type=>'TuftsSelfDeposit', :tufts_self_deposit=>{:title=>"My self-deposit"}
        assigns[:self_deposit].accrualPolicy.join.should include "self-deposit"
      end

      it "should include the username in the provenance" do
        post :create, :type=>'TuftsSelfDeposit', :tufts_self_deposit=>{:title=>"My self-deposit"}
        assigns[:self_deposit].provenance.join.should include @user.to_s
      end

    end
  end
end
