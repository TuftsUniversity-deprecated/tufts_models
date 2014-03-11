require 'spec_helper'

describe Job::ApplyTemplate do

  before do
    @user = FactoryGirl.create :user
    @obj = TuftsPdf.new(title: 'Hello', displays: ['dl'])
    @obj.save!
  end

  after do
    @user.delete
    @obj.delete
  end


  it 'uses the "templates" queue' do
    job = Job::ApplyTemplate.new('1', '1', {})
    job.queue_name.should == :templates
  end

  describe '#initialize' do
    before do
      @attrs = { title: 'My Template', subject: 'My Subject' }
      @job = Job::ApplyTemplate.new(@user.id, @obj.id, @attrs)
    end

    it 'sets the user key' do
      @job.user_id.should == @user.id
    end

    it 'sets the record id' do
      @job.record_id.should == @obj.id
    end

    it 'sets the attributes for update' do
      @job.attributes.should == @attrs
    end
  end


  describe '#run' do
    it 'raises an error if it fails to find the object' do
      obj_id = 'tufts:1'
      TuftsPdf.find(obj_id).destroy if TuftsPdf.exists?(obj_id)

      job = Job::ApplyTemplate.new(1, obj_id, {})
      expect {
        job.run
      }.to raise_error(ActiveFedora::ObjectNotFoundError)
    end

    it 'updates the record' do
      object = TuftsPdf.new(title: 'old title', toc: 'old toc', displays: ['dl'])
      object.save!
      job = Job::ApplyTemplate.new(1, object.id, {toc: 'new toc'})
      job.run
      object.reload
      object.toc.should == ['old toc', 'new toc']
    end
  end

end
