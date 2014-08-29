require 'spec_helper'


describe Audit do
  it "should store properties" do
    subject.who = 'Sara'
    subject.what = 'Updated metadata'
    subject.when = DateTime.now

    expect(subject.who).to eq ['Sara']
    expect(subject.what).to eq ['Updated metadata']
    expect(subject.when.first).to be_kind_of DateTime
  end
end
