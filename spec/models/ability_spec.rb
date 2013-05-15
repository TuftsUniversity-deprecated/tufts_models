require 'spec_helper'
require "cancan/matchers"

describe Ability do
  describe "an admin user" do
    subject { Ability.new(FactoryGirl.create(:admin))}
    describe "working on Roles" do
      it { should be_able_to(:index, Role) }
      it { should be_able_to(:create, Role) }
      it { should be_able_to(:show, Role) }
      it { should be_able_to(:add_user, Role) }
      it { should be_able_to(:remove_user, Role) }
    end

    describe "working on TuftsAudio" do
      before :all do
        @audio = TuftsAudio.create!(title: 'test audio')
      end
      after :all do
        @audio.destroy
      end
      it { should be_able_to(:create, TuftsAudio) }
      it { should be_able_to(:edit, @audio) }
      it { should be_able_to(:update, @audio) }
      it { should be_able_to(:publish, @audio) }
    end
  end

  describe "a non-admin user" do
    subject { Ability.new(FactoryGirl.create(:user))}
    it { should_not be_able_to(:index, Role) }
    it { should_not be_able_to(:create, Role) }
    it { should_not be_able_to(:show, Role) }
    it { should_not be_able_to(:add_user, Role) }
  end

end

