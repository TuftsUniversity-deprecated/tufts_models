require 'spec_helper'

describe 'deposit_types/edit.html.erb' do
  before :each do
    @dt = FactoryGirl.create(:deposit_type)
    assign :deposit_type, @dt
    render
  end

  it 'displays the form fields' do
    assert_select('form') do
      assert_select('#deposit_type_display_name', value: @dt.display_name)
      assert_select('#deposit_type_deposit_view', value: @dt.deposit_view)
      assert_select('#deposit_type_deposit_agreement', value: @dt.deposit_agreement)
      assert_select('#deposit_type_license_name', value: @dt.license_name)
      assert_select 'input[type=?]', 'submit'
    end
  end
end
