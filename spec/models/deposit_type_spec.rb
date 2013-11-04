require 'spec_helper'

describe DepositType do

  it 'has a valid factory' do
    FactoryGirl.create(:deposit_type).should be_valid
  end

  it 'requires a display_name' do
    dt = FactoryGirl.create(:deposit_type)
    dt.display_name.should include 'Deposit Type'
    FactoryGirl.build(:deposit_type, display_name: nil).should_not be_valid
  end

  it 'requires a license_name' do
    dt = FactoryGirl.create(:deposit_type)
    dt.license_name.should include 'Generic Deposit Agreement v1.0'
    FactoryGirl.build(:deposit_type, license_name: nil).should_not be_valid
  end

  it 'rejects license_name over 50 characters' do
    hundred = '1234567890' * 10
    dt = FactoryGirl.build(:deposit_type, license_name: hundred).should_not be_valid
  end

  it 'requires a deposit_view' do
    dt = FactoryGirl.create(:deposit_type)
    dt.deposit_view.should == 'generic_deposit'
    FactoryGirl.build(:deposit_type, deposit_view: nil).should_not be_valid
  end

  it 'has a deposit_agreement'do
    dt = FactoryGirl.create(:deposit_type)
    dt.deposit_agreement.should == 'legal jargon here...'
  end

  it 'must have unique display names' do
    dt = FactoryGirl.create(:deposit_type)
    FactoryGirl.build(:deposit_type, display_name: dt.display_name).should_not be_valid
  end

  it 'must have a deposit_view that points to a vaild partial' do
    FactoryGirl.build(:deposit_type, deposit_view: 'invalid_view_partial').should_not be_valid
  end

  it 'sanitizes deposit_agreement input' do
    bad_text = "<script> JS Attack! </script> <a href='/license'>Legitimate Link</a>"
    dt = FactoryGirl.create(:deposit_type, deposit_agreement: bad_text)
    dt.deposit_agreement.match(/script/).should be_nil
    dt.deposit_agreement.match(/href="\/license"/).should_not be_nil
    dt.deposit_agreement.match(/<\/a>/).should_not be_nil
  end
end
