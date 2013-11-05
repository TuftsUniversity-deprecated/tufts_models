require 'spec_helper'

describe 'deposit_types/new.html.erb' do
  before :each do
    assign :deposit_type, DepositType.new
    render
  end

  it 'should have a display_name field' do
    rendered.should have_field('deposit_type[display_name]', type: 'text')
  end

  it 'should have a license_name field' do
    rendered.should have_field('deposit_type[license_name]', type: 'text')
  end

  it 'should have a deposit_view field' do
    rendered.should have_field('deposit_type[deposit_view]', type: 'select')
  end

  it 'should have a deposit_agreement field' do
    rendered.should have_field('deposit_type[deposit_agreement]', type: 'textarea')
  end

  it 'should have a Create button' do
    rendered.should have_button('Save')
  end

  it 'should have a Cancel link' do
    rendered.should have_link('Back', href: deposit_types_path)
  end

end
