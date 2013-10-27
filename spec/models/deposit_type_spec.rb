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
end
