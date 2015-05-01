require 'spec_helper'

class TestObject < ActiveFedora::Base
  include BaseModel
end


describe BaseModel do
  subject { TestObject.new(attrs) }

  context 'when reverting an object' do
    let(:xmas) { DateTime.parse('2014-12-25 11:30') }
    let(:attrs) {{ edited_at: xmas, published_at: xmas }}

    # Don't change edited_at when reverting.
    # When you revert a record as part of a batch of jobs
    # the batch_id will be added to the record, which causes
    # the record to be saved again.
    # If we allow edited_at to update during the save, then
    # after the revert the draft record will have the state
    # :edited instead of the correct state :published.
    # (because edited_at won't match published_at).

    it 'doesnt change the edited_at time' do
      expect(subject.edited_at).to eq xmas
      subject.reverting = true
      subject.save!
      expect(subject.edited_at).to eq xmas
    end

  end

end
