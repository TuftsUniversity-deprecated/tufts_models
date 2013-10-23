require 'spec_helper'

describe User do

  it 'by default has the role of a registered user (after it is saved)' do
    user = FactoryGirl.build(:user)
    user.registered?.should be_false
    user.save
    user.registered?.should be_true
  end

  describe "an admin" do
    subject { FactoryGirl.create(:admin) }
    its(:groups) {should include('admin')}
  end

end
