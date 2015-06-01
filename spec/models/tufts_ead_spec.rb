require 'spec_helper'

describe TuftsEAD do

  it 'has methods to support a draft version of the object' do
    expect(described_class).to respond_to(:build_draft_version)
  end

  describe "#default_datastream" do
    subject { described_class.default_datastream }
    it { is_expected.to eq 'Archival.xml' }
  end

  describe "to_class_uri" do
    subject { described_class.to_class_uri }
    it { is_expected.to eq 'info:fedora/cm:Text.EAD' }
  end
end
