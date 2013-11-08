require 'spec_helper'

describe Sequence do
  it "should have a format like tufts:sd.0000000" do
    Sequence.next_val.should match /^tufts:sd.000000\d$/
  end
end
