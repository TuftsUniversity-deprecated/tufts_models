require 'spec_helper'

describe User do
  describe "a contributor" do
    subject { FactoryGirl.create(:user) }
    its(:groups) {should include('contributor')}
  end

  describe "an admin" do
    subject { FactoryGirl.create(:admin) }
    its(:groups) {should include('admin')}
  end
end
