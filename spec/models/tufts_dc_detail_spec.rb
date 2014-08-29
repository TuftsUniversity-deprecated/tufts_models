require 'spec_helper'

describe TuftsDcDetailed do
  it "should have provenance" do
    subject.provenance = 'test'
    expect(subject.provenance).to eq ['test']
  end
end

