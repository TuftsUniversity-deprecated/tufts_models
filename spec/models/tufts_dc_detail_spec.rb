require 'spec_helper'

describe TuftsDcDetailed do
  it "should have provenance" do
    subject.provenance = 'test'
    expect(subject.provenance).to eq ['test']
  end

  describe "#to_solr" do
    let(:model) { TuftsDcDetailed.new(nil, nil) }
    before do
      model.spatial = ['Florence', 'Firenze']
    end

    subject { model.to_solr }

    it { should eq('spatial_tesim' => ['Florence', 'Firenze']) }

  end
end

