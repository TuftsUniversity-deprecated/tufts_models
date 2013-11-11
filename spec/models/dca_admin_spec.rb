require 'spec_helper'

describe DcaAdmin do
  it "should have a published date" do
    time = DateTime.parse('2013-03-22T12:33:00Z')
    subject.published_at = time
    subject.published_at.should == [time]
  end

  it "should have an edited date" do
    time = DateTime.parse('2013-03-22T12:33:00Z')
    subject.edited_at = time
    subject.edited_at.should == [time]
  end

  it "should index the published and edited dates" do
    time = DateTime.parse('2013-03-22T12:33:00Z')
    subject.edited_at = time
    subject.published_at = time
    subject.to_solr.should == {
       "edited_at_dtsi" =>'2013-03-22T12:33:00Z', 'published_at_dtsi' =>'2013-03-22T12:33:00Z'}
  end

  it "should have note" do
    subject.note = 'self-deposit'
    expect(subject.note).to eq ['self-deposit']
    subject.note = 'admin-deposit'
    expect(subject.note).to eq ['admin-deposit']
  end

  it "should have createdby" do
    subject.createdby = Contribution::SELFDEP
    expect(subject.createdby).to eq [Contribution::SELFDEP]
    subject.createdby = 'admin-deposit'
    expect(subject.createdby).to eq ['admin-deposit']
  end

  it "should have creatordept" do
    subject.creatordept = 'Dept. of Biology'
    expect(subject.creatordept).to eq ['Dept. of Biology']
  end
end
