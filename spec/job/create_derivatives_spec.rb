require 'spec_helper'

describe Job::CreateDerivatives do

  it 'uses the "derivatives" queue' do
    expect(Job::CreateDerivatives.queue).to eq :derivatives
  end

  describe '::create' do
    it 'requires the record id' do
      expect{Job::CreateDerivatives.create({})}.to raise_exception(ArgumentError)
    end
  end


  describe '#perform' do
    it 'raises an error if it fails to find the object' do
      obj_id = 'tufts:1'
      TuftsPdf.find(obj_id).destroy if TuftsPdf.exists?(obj_id)

      job = Job::CreateDerivatives.new('uuid', 'record_id' => obj_id)
      expect{job.perform}.to raise_error(ActiveFedora::ObjectNotFoundError)
    end

    it 'creates derivatives' do
      object = TuftsPdf.new(title: 'old title', toc: ['old toc'], displays: ['dl'])
      object.save!
      job = Job::CreateDerivatives.new('uuid', 'record_id' => object.id)

      expect_any_instance_of(TuftsPdf).to receive(:create_derivatives)
      expect_any_instance_of(TuftsPdf).to receive(:save)
      job.perform
    end
  end

end
