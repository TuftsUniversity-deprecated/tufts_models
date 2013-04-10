require 'spec_helper'

feature 'Visitor signs up' do
  scenario 'with valid email and password' do
    sign_up_with 'valid@example.com', 'password'

    page.should have_content('Log Out')
  end

  scenario 'with invalid email' do
    sign_up_with 'invalid_email', 'password'

    page.should have_content('Sign in')
  end

  scenario 'with blank password' do
    sign_up_with 'valid@example.com', ''

    page.should have_content('Sign in')
  end 
end

