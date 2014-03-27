require 'spec_helper'

describe Job::ApplyTemplate do

  it 'uses the "templates" queue' do
    Job::ApplyTemplate.queue.should == :templates
  end

  describe '::create' do
    it 'requires the user id' do
      expect{Job::ApplyTemplate.create('record_id' => '1', 'attributes' => {})}.to raise_exception(ArgumentError)
    end

    it 'requires the record id' do
      expect{Job::ApplyTemplate.create('user_id' => '1', 'attributes' => {})}.to raise_exception(ArgumentError)
    end

    it 'requires the attributes for update' do
      expect{Job::ApplyTemplate.create('user_id' => '1', 'record_id' => '1')}.to raise_exception(ArgumentError)
    end
  end


  describe '#perform' do
    it 'raises an error if it fails to find the object' do
      obj_id = 'tufts:1'
      TuftsPdf.find(obj_id).destroy if TuftsPdf.exists?(obj_id)

      job = Job::ApplyTemplate.new('uuid', 'user_id' => 1, 'record_id' => obj_id, 'attributes' => {})
      expect{job.perform}.to raise_error(ActiveFedora::ObjectNotFoundError)
    end

    it 'updates the record' do
      object = TuftsPdf.new(title: 'old title', toc: 'old toc', displays: ['dl'])
      object.save!
      job = Job::ApplyTemplate.new('uuid', 'user_id' => 1, 'record_id' => object.id, 'attributes' => {toc: 'new toc'})
      job.perform
      object.reload
      object.toc.should == ['old toc', 'new toc']
    end
  end
end
