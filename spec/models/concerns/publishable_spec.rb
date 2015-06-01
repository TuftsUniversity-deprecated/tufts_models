require 'spec_helper'

class TestObject < ActiveFedora::Base
  include Publishable
end

describe Publishable do

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

  describe '#find_draft' do
    before { ActiveFedora::Base.delete_all }

    let!(:record) { TestObject.create!(pid: 'tufts:123') }

    context 'given a record with a draft version' do
      let!(:draft_record) {
        TestObject.build_draft_version(record.attributes.except('id').merge(pid: record.pid)).tap do |obj|
          obj.save!
        end
      }

      it 'finds the draft version of that record' do
        expect(record.find_draft).to eq draft_record
      end

      it "just returns self if it's already a draft record" do
        expect(draft_record.class).to_not receive(:find)
        expect(draft_record.find_draft).to eq draft_record
      end
    end

    context 'given a record without a draft version' do
      it 'raises an exception' do
        expect { record.find_draft }.to raise_error ActiveFedora::ObjectNotFoundError
      end
    end
  end

  describe '#find_published' do
    before { ActiveFedora::Base.delete_all }
    let!(:draft)  { TestObject.create!(pid: 'draft:123') }

    context 'when there is a published record' do
      let!(:record) { TestObject.create!(pid: 'tufts:123') }

      it 'finds the published version of the draft' do
        expect(draft.find_published).to eq record
      end

      it "just returns self if it's already a published record" do
        expect(record.class).to_not receive(:find)
        expect(record.find_published).to eq record
      end
    end

    context "when a published record doesn't exist" do
      it 'raises an exception' do
        expect{ draft.find_published }.to raise_error ActiveFedora::ObjectNotFoundError
      end
    end
  end


  describe '#draft?' do
    subject { TestObject.new(pid: pid, namespace: namespace) }

    context 'with a non-draft PID' do
      let(:pid) { 'tufts:123' }
      let(:namespace) { nil }

      it 'reports non-draft status' do
        expect(subject.draft?).to be_falsey
      end
    end

    context 'a PID with the draft namespace' do
      let(:pid) { 'draft:123' }
      let(:namespace) { nil }

      it 'reports draft status' do
        expect(subject.draft?).to be_truthy
      end
    end

    context 'with no PID, but draft namespace' do
      let(:pid) { nil }
      let(:namespace) { PidUtils.draft_namespace }

      it 'reports draft status' do
        expect(subject.draft?).to be_truthy
      end
    end

    context 'with no PID, but non-draft namespace' do
      let(:pid) { nil }
      let(:namespace) { PidUtils.published_namespace }

      it 'reports non-draft status' do
        expect(subject.draft?).to be_falsey
      end
    end

    context 'with no PID and no namespace' do
      let(:pid) { nil }
      let(:namespace) { nil }

      it 'reports non-draft status' do
        expect(subject.draft?).to be_falsey
      end
    end
  end

end
