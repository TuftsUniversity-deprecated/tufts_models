require 'spec_helper'
require "cancan/matchers"

describe Ability do
  before :all do
    User.delete_all
    @user = FactoryGirl.create(:user, email: 'user@example.com')
    @another_user = FactoryGirl.create(:user, email: 'another_user@example.com')
    @admin = FactoryGirl.create(:admin, email: 'admin@example.com')
  end

  describe "an admin user" do
    subject { Ability.new(@admin) }

    describe "working on Roles" do
      it { should be_able_to(:index, Role) }
      it { should be_able_to(:create, Role) }
      it { should be_able_to(:show, Role) }
      it { should be_able_to(:add_user, Role) }
      it { should be_able_to(:remove_user, Role) }
    end

    describe "working on Deposit Type" do
      it { should be_able_to(:create, TuftsDepositType) }
      it { should be_able_to(:read, TuftsDepositType) }
      it { should be_able_to(:update, TuftsDepositType) }
      it { should be_able_to(:destroy, TuftsDepositType) }
      it { should be_able_to(:export, TuftsDepositType) }
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
      it { should be_able_to(:destroy, @audio) }
    end
  end

  describe "a non-admin user" do
    subject { Ability.new(@user) }

    describe "working on Roles" do
      it { should_not be_able_to(:index, Role) }
      it { should_not be_able_to(:create, Role) }
      it { should_not be_able_to(:show, Role) }
      it { should_not be_able_to(:add_user, Role) }
      it { should_not be_able_to(:remove_user, Role) }
    end

    describe "working on Deposit Type" do
      it { should_not be_able_to(:create, TuftsDepositType) }
      it { should_not be_able_to(:read, TuftsDepositType) }
      it { should_not be_able_to(:update, TuftsDepositType) }
      it { should_not be_able_to(:destroy, TuftsDepositType) }
      it { should_not be_able_to(:export, TuftsDepositType) }
    end

    describe "working on a self-deposit" do
      before :all do
        @self_deposit = FactoryGirl.create(:tufts_self_deposit, user: @user)
        @another_deposit = FactoryGirl.create(:tufts_self_deposit, user: @another_user)
      end
      after :all do
        @self_deposit.destroy
        @another_deposit.destroy
      end

      it { should     be_able_to(:create, TuftsSelfDeposit) }
      it { should     be_able_to(:read, @self_deposit) }
      it { should_not be_able_to(:read, @another_deposit) }
      it { should     be_able_to(:update, @self_deposit) }
      it { should_not be_able_to(:update, @another_deposit) }
      it { should     be_able_to(:destroy, @self_deposit) }
      it { should_not be_able_to(:destroy, @another_deposit) }
      it { should_not be_able_to(:publish, @self_deposit) }
      it { should_not be_able_to(:publish, @another_deposit) }
    end
  end

  describe "a non-authenticated user" do
    let(:not_logged_in) { User.new }
    subject { Ability.new(not_logged_in) }

    describe "working on Roles" do
      it { should_not be_able_to(:index, Role) }
      it { should_not be_able_to(:create, Role) }
      it { should_not be_able_to(:show, Role) }
      it { should_not be_able_to(:add_user, Role) }
      it { should_not be_able_to(:remove_user, Role) }
    end

    describe "working on Deposit Type" do
      it { should_not be_able_to(:create, TuftsDepositType) }
      it { should_not be_able_to(:read, TuftsDepositType) }
      it { should_not be_able_to(:update, TuftsDepositType) }
      it { should_not be_able_to(:destroy, TuftsDepositType) }
      it { should_not be_able_to(:export, TuftsDepositType) }
    end

    describe "working on a self-deposit" do
      before :all do
        @self_deposit = FactoryGirl.create(:tufts_self_deposit, user: @user)
      end
      after :all do
        @self_deposit.destroy
      end

      it { should_not be_able_to(:create, TuftsSelfDeposit) }
      it { should_not be_able_to(:read, @self_deposit) }
      it { should_not be_able_to(:update, @self_deposit) }
      it { should_not be_able_to(:destroy, @self_deposit) }
      it { should_not be_able_to(:publish, @self_deposit) }
    end
  end

end
