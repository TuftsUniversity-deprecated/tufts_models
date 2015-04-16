require 'spec_helper'

class TestObject < ActiveFedora::Base
  include DraftVersion
end


describe DraftVersion do

  describe '.build_draft_version' do
    subject { TestObject.build_draft_version(attrs) }

    context 'with no PID given' do
      let(:attrs) { Hash.new }

      it 'sets the draft namespace so that the saved object will have a draft PID' do
        expect(subject.inner_object.namespace).to eq 'draft'
        expect(subject.pid).to be_nil
        subject.save!
        expect(subject.pid).to match /^draft:.*$/
      end
    end

    context 'with a namespace given' do
      let(:attrs) {{ namespace: 'tufts' }}

      it 'overrides the namespace with the draft namespace' do
        expect(subject.inner_object.namespace).to eq 'draft'
      end
    end

    context 'with a non-draft PID given' do
      let(:pid) { 'tufts:123' }
      let(:draft_pid) { 'draft:123' }
      let(:attrs) {{ pid: pid }}

      it 'converts the PID to a draft PID' do
        expect(subject.pid).to eq draft_pid
      end
    end
  end

  describe '#publish!' do
    let(:user) { FactoryGirl.create(:user) }

    before do
      @obj = TuftsImage.create(title: 'My title', displays: ['dl'])
    end

    after do
      @obj.delete if @obj
    end

    context "when a published version does not exist" do
      it "results in a published copy of the draft existing" do
        published_pid = PidUtils.to_published(@obj.pid)
        expect(TuftsImage.exists?(published_pid)).to be_falsey

        @obj.publish!

        expect(TuftsImage.exists?(published_pid)).to be_truthy
      end
    end

    context "when a published version already exists" do
      it "destroys the existing published copy" do
        published_pid = PidUtils.to_published(@obj.pid)

        @obj.publish!

        expect(TuftsImage).to receive(:destroy).with(published_pid).once { true }

        @obj.publish!
      end

      it "results in a published copy of the original"
    end


    it 'adds an entry to the audit log' do
      expect(@obj).to receive(:audit).with(instance_of(User), 'Pushed to production').once

      # This needs to be happen a number of times because of the multiple object updates in #publish!
      expect(@obj).to receive(:audit).with(instance_of(User), 'Metadata updated DCA-ADMIN').twice

      @obj.publish!(user.id)
    end

    it 'results in the image being published' do
      skip "this test randomly fails"

      expect(@obj.published_at).to eq(nil)

      @obj.publish!
      @obj.reload
      expect(@obj.published?).to be_truthy
    end

    it 'only updates the published_at time when actually published' do
      expect(@obj.published_at).to eq nil

      @obj.publish!(user.id)

      expect(@obj.admin.published_at.first).to be_within(1.second).of(@obj.edited_at)
    end
  end

end
