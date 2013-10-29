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
    end
    describe 'for authenticated users' do
      before :each do
        sign_in :user
      end
      it 'should exist' do
        visit '/contribute'
        current_path.should == contribute_path
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