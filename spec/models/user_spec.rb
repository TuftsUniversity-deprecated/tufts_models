require 'spec_helper'

describe User do
  describe "an admin" do
    subject { FactoryGirl.create(:admin) }
    its(:groups) {should include('admin')}
  end
end
