require 'spec_helper'

describe 'Contribute' do

  describe "Landing Page" do
    it "should exist" do
      visit '/contribute'
      current_path.should == contribute_path
    end
    it 'should give a login option' do
      visit '/contribute'
      expect(page).to have_content 'Tufts Simplified Sign-On Enabled'
      expect(page).to have_link 'Login'
    end
  end
end