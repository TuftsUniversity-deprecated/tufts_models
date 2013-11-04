require 'spec_helper'
require "cancan/matchers"

describe SelfDepositsController do
  describe "A contributor" do
    let (:user) { FactoryGirl.create(:admin) }
    before do
      sign_in user
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
        assigns[:self_deposit].creator.should include user.to_s
      end

      it "should list deposit_method as self deposit" do
        now = Time.now
        Time.stub(:now).and_return(now)
        post :create, :type=>'TuftsSelfDeposit', :tufts_self_deposit=>{:title=>"My self-deposit"}
        expect(assigns[:self_deposit].note.first).to eq "#{user.user_key} self-deposited on #{now.strftime('%Y-%m-%d at %H:%M:%S %Z')} using the Deposit Form for the Tufts Digital Library"
      end
    end
  end
end
