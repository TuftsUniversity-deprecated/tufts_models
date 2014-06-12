require 'spec_helper'

describe User do

  it 'by default has the role of a registered user (after it is saved)' do
    user = FactoryGirl.build(:user)
    user.registered?.should be_falsey
    user.save
    user.registered?.should be_truthy
  end

  describe "an admin" do
    subject { FactoryGirl.create(:admin) }
    it "is in the admin group" do
      expect(subject.groups).to include('admin')
    end
  end

end
