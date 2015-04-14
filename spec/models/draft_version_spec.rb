require 'spec_helper'

class TestObject < ActiveFedora::Base
  include DraftVersion
end


describe DraftVersion do

  describe '.draft_namespace' do
    it 'returns the namespace for draft PIDs' do
      expect(TestObject.draft_namespace).to eq 'draft'
    end
  end

  describe '.production_namespace' do
    it 'returns the namespace for a production PID' do
      expect(TestObject.production_namespace).to eq 'tufts'
    end
  end

  describe '.stripped_pid' do
    it 'returns the pid with the namespace stripped off' do
      expect(TestObject.stripped_pid('tufts:123')).to eq '123'
    end
  end

  describe '.draft_pid' do
    let(:pid) { 'tufts:123' }
    let(:draft_pid) { 'draft:123' }

    it 'converts a PID to a draft PID' do
      expect(TestObject.draft_pid(pid)).to eq draft_pid
    end
  end

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

end
