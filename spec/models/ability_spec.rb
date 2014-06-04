require 'spec_helper'
require "cancan/matchers"

describe Ability do
  before :all do
    User.delete_all
    @user = FactoryGirl.create(:user)
    @admin = FactoryGirl.create(:admin)
  end

  describe "an admin user" do
    subject { Ability.new(@admin) }

    describe "using the catalog" do
      it { should be_able_to(:read, SolrDocument) }
    end

    describe "working on Roles" do
      it { should be_able_to(:index, Role) }
      it { should be_able_to(:create, Role) }
      it { should be_able_to(:show, Role) }
      it { should be_able_to(:add_user, Role) }
      it { should be_able_to(:remove_user, Role) }
    end

    describe "batch operations" do
      it { should be_able_to(:index, Batch) }
      it { should be_able_to(:new_template_import, Batch) }
      it { should be_able_to(:new_xml_import, Batch) }
      it { should be_able_to(:create, Batch) }
      it { should be_able_to(:show, Batch) }
      it { should be_able_to(:edit, Batch) }
      it { should be_able_to(:update, Batch) }
    end

    describe "working on Deposit Type" do
      it { should be_able_to(:create, DepositType) }
      it { should be_able_to(:read, DepositType) }
      it { should be_able_to(:update, DepositType) }
      it { should be_able_to(:destroy, DepositType) }
      it { should be_able_to(:export, DepositType) }
    end

    describe "working on TuftsAudio" do
      before :all do
        @audio = TuftsAudio.create!(title: 'test audio', displays: ['dl'])
      end
      after :all do
        @audio.destroy
      end
      it { should be_able_to(:create, TuftsAudio) }
      it { should be_able_to(:edit, @audio) }
      it { should be_able_to(:update, @audio) }
      it { should be_able_to(:review, @audio) }
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

    describe "batch operations" do
      it { should_not be_able_to(:index, Batch) }
      it { should_not be_able_to(:new_template_import, Batch) }
      it { should_not be_able_to(:new_xml_import, Batch) }
      it { should_not be_able_to(:create, Batch) }
      it { should_not be_able_to(:show, Batch) }
      it { should_not be_able_to(:edit, Batch) }
      it { should_not be_able_to(:update, Batch) }
    end

    describe "working on Deposit Type" do
      it { should_not be_able_to(:create, DepositType) }
      it { should_not be_able_to(:read, DepositType) }
      it { should_not be_able_to(:update, DepositType) }
      it { should_not be_able_to(:destroy, DepositType) }
      it { should_not be_able_to(:export, DepositType) }
    end

    describe "working on a self-deposit" do
      it { should be_able_to(:create, Contribution) }
    end

    describe "working on TuftsPdf" do
      describe "that they own" do
        before :all do
          @self_deposit = FactoryGirl.create(:tufts_pdf, user: @user)
        end
        after :all do
          @self_deposit.destroy
        end

        it { should     be_able_to(:read, @self_deposit) }
        it { should     be_able_to(:update, @self_deposit) }
        it { should     be_able_to(:destroy, @self_deposit) }
        it { should_not be_able_to(:publish, @self_deposit) }
        it { should_not be_able_to(:review, @self_deposit) }
      end

      describe "that they don't own" do
        before :all do
          @another_deposit = FactoryGirl.create(:tufts_pdf)
        end
        after :all do
          @another_deposit.destroy
        end

        it { should_not be_able_to(:read, @another_deposit) }
        it { should_not be_able_to(:update, @another_deposit) }
        it { should_not be_able_to(:destroy, @another_deposit) }
        it { should_not be_able_to(:publish, @another_deposit) }
        it { should_not be_able_to(:review, @another_deposit) }
      end
    end

    describe "working on TuftsAudio" do
      it { should_not be_able_to(:create, TuftsAudio) }

      describe "that they own" do
        before :all do
          @audio = FactoryGirl.create(:tufts_audio, user: @user)
        end
        after :all do
          @audio.destroy
        end
        it { should     be_able_to(:edit, @audio) }
        it { should     be_able_to(:update, @audio) }
        it { should_not be_able_to(:review, @audio) }
        it { should_not be_able_to(:publish, @audio) }
        it { should     be_able_to(:destroy, @audio) }
      end

      describe "that they don't own" do
        before :all do
          @audio = FactoryGirl.create(:tufts_audio)
        end
        after :all do
          @audio.destroy
        end
        it { should_not be_able_to(:edit, @audio) }
        it { should_not be_able_to(:update, @audio) }
        it { should_not be_able_to(:review, @audio) }
        it { should_not be_able_to(:publish, @audio) }
        it { should_not be_able_to(:destroy, @audio) }
      end
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
      it { should_not be_able_to(:create, DepositType) }
      it { should_not be_able_to(:read, DepositType) }
      it { should_not be_able_to(:update, DepositType) }
      it { should_not be_able_to(:destroy, DepositType) }
      it { should_not be_able_to(:export, DepositType) }
    end
    
    describe "working on a PDF" do
      let(:pdf) { TuftsPdf.create!(title: 'test pdf', read_groups: ['public'], displays: ['dl'])}
      after { pdf.destroy }

      it "should be visible to a not-signed-in user" do
        subject.should be_able_to(:read, pdf.pid)
      end
    end

    describe "working on a self-deposit" do
      it { should_not be_able_to(:create, Contribution) }
    end

    describe "viewing a public audio file" do
      let(:audio) do
        audio = TuftsAudio.new(title: 'foo', displays: ['dl'])
        audio.read_groups = ['public']
        audio.save!
        audio
      end

      it { should be_able_to(:read, audio) }
    end
  end
end
