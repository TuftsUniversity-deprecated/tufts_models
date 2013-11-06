require 'spec_helper'

describe 'User sign up' do

  it 'creates a new user' do
    User.delete_all
    visit new_user_registration_path
    within '#new_user' do
      fill_in('Email', :with => 'frodo@example.com')
      fill_in('Password', :with => 'password')
      fill_in('Password confirmation', :with => 'password')
      click_on('Sign up')
    end
    User.count.should == 1
    page.should have_link('Log Out')
  end

end
