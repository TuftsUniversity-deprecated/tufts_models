require 'spec_helper'

describe Sequence do
  before { Sequence.delete_all }

  it "should have a format like tufts:sd.0000000" do
    expect(Sequence.next_val).to match /^tufts:sd\.\d{7}$/
  end

  describe "scope" do
    it "makes the sequences independent" do
      one = Sequence.next_val(scope: 'handle', format: '%d')
      two = Sequence.next_val(format: '%d')
      expect(one).to eq two
      three = Sequence.next_val(format: '%d')
      expect(two).not_to eq three
    end
  end

  context "with scope and format" do
    subject { Sequence.next_val(scope: 'handle', format: '%d') }
    it { is_expected.to eq '1' }
  end
end
