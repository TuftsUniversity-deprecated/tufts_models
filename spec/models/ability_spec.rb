require 'spec_helper'
require "cancan/matchers"

describe Ability do
  let(:another_user) { FactoryGirl.create(:user) }

  describe "an admin user" do
    subject { Ability.new(FactoryGirl.create(:admin))}
    it { should be_able_to(:edit, another_user) }
    it { should be_able_to(:index, Role) }
    it { should be_able_to(:create, Role) }
    it { should be_able_to(:show, Role) }
  end

  describe "a non-admin user" do
    subject { Ability.new(FactoryGirl.create(:user))}
    it { should_not be_able_to(:edit, another_user) }
    it { should_not be_able_to(:index, Role) }
    it { should_not be_able_to(:create, Role) }
    it { should_not be_able_to(:show, Role) }
  end

end

