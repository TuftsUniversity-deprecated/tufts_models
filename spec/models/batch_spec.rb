require 'spec_helper'

describe Batch do
  subject { Batch.new }

  it "requires a creator" do
    expect(subject.valid?).to be_false
  end

  it "requires children to implement ready?" do
    expect{Batch.new.ready?}.to raise_error(NotImplementedError)
  end

  it "requires children to implement run" do
    expect{Batch.new.run}.to raise_error(NotImplementedError)
  end
end
