require 'spec_helper'

describe PidUtils do

  describe '.draft_namespace' do
    it 'returns the namespace for draft PIDs' do
      expect(PidUtils.draft_namespace).to eq 'draft'
    end
  end

  describe '.published_namespacs' do
    it 'returns the namespace for a published PID' do
      expect(PidUtils.published_namespace).to eq 'tufts'
    end
  end

  describe '.stripped_pid' do
    it 'returns the pid with the namespace stripped off' do
      expect(PidUtils.stripped_pid('tufts:123')).to eq '123'
    end
  end

  describe '.to_draft' do
    it 'converts a published pid to a draft pid' do
      expect(PidUtils.to_draft('tufts:123')).to eq 'draft:123'
      expect(PidUtils.to_draft('draft:123')).to eq 'draft:123'
      expect(PidUtils.to_draft('123')).to eq 'draft:123'
    end
  end

end
