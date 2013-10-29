require 'spec_helper'

describe 'Contribute' do

  it 'should be default path for unauthenticated users' do
    visit destroy_user_session_path
    visit '/'
    current_path.should == '/contribute'
  end

  it 'should be the default root for authenticated non-admin users' do
    sign_in :user
    visit '/'
    current_path.should == '/contribute'
  end

  describe "Landing Page" do
    before :all do
      @deposit_type = DepositType.new(:display_name => 'Test Option', :deposit_view => 'generic_deposit', :deposit_agreement => 'Legal links here...')
      @deposit_type.save!
    end

    after :all do
      @deposit_type.destroy
    end

    describe 'for unauthenticated users' do
      before :all do
        visit destroy_user_session_path
      end
      it 'should exist' do
        visit '/contribute'
        current_path.should == contribute_path
      end
      it 'should give a login option' do
        visit '/contribute'
        expect(page).to have_content 'Tufts Simplified Sign-On Enabled'
        expect(page).to have_link 'Login'
      end
      it 'should show configured deposit type options' do
        visit '/contribute'
        expect(page).to have_content 'Test Option'
      end
    end
    describe 'for authenticated users' do
      before :each do
        sign_in :user
      end
      it 'should exist' do
        visit '/contribute'
        current_path.should == contribute_path
      end
      it 'should let users select a deposit type' do
        visit '/contribute'
        page.should have_select 'deposit_type'
      end
      it 'should provide a button to create new deposits' do
        page.should have_button 'Begin'
      end
    end
  end

  describe 'License Page' do
    it 'should contain the license description' do
      visit '/contribute/license'
      expect(page).to have_content 'Non-Exclusive Deposit License'
    end
  end
end