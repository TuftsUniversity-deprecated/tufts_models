require 'spec_helper'

describe 'Contribute' do

  before :all do
    @deposit_type = DepositType.new(:display_name => 'Test Option', :deposit_view => 'generic_deposit', :deposit_agreement => 'Legal links here...')
    @deposit_type.save!
  end

  after :all do
    @deposit_type.destroy
  end


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

  describe 'New file deposit page' do
    it 'should redirect unauthenticated users to the sign-on page' do
      visit destroy_user_session_path # Force logout, just in case...
      visit '/contribute/new'
      current_path.should == new_user_session_path
    end
    describe 'for authenticated users' do
      before :each do
        sign_in :user     end
      it 'should redirect the user to the selection page is the deposit type is missing' do
        visit '/contribute/new'
        current_path.should == contribute_path
      end
      it 'should redirect the user to the selection page is the deposit type is invalid' do
        visit '/contribute/new?type=bad_deposit_type'
        current_path.should == contribute_path
      end
      it 'should accept valid deposit types' do
        visit "/contribute/new?deposit_type=#{@deposit_type.id}"
        current_path.should == new_contribute_path
      end

    end
  end

end

