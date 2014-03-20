require 'spec_helper'

describe TuftsTemplate do

  it 'most metadata attributes are not required' do
    subject.required?(:title).should be_false
    subject.required?(:displays).should be_false
  end

  describe 'template_name attribute' do
    it 'getter and setter methods exist' do
      subject.template_name = 'Title #1'
      subject.template_name.should == 'Title #1'
    end

    it 'is required' do
      subject.required?(:template_name).should be_true
    end
  end

  describe 'publishing' do
    it 'cannot be pushed to the production environment' do
      expect{ subject.push_to_production! }.to raise_error(UnpublishableModelError)
    end

    it 'is never published' do
      subject.published?.should be_false
    end
  end

  describe '#attributes_to_update' do
    it "removes attributes that aren't in the edit list" do
      attrs = { title: 'Title from template',
                filesize: ['57 MB'],
                discover_users: ['someone@example.com'] }
      template = TuftsTemplate.new(attrs)

      # This test assumes that :discover_users is not included
      # in terms_for_editing, but the other attributes are
      template.terms_for_editing.include?(:title).should be_true
      template.terms_for_editing.include?(:filesize).should be_true
      template.terms_for_editing.include?(:discover_users).should be_false

      # Any attributes that aren't in terms_for_editing should
      # not be included in our result
      result = template.attributes_to_update
      result.class.should == Hash
      result.include?(:title).should be_true
      result.include?(:filesize).should be_true
      result.include?(:discover_users).should be_false
    end

    it 'includes stored_collection_id' do
      attrs = { stored_collection_id: 'collection:123',
                filesize: ['57 MB'] }
      template = TuftsTemplate.new(attrs)
      result = template.attributes_to_update
      result.include?(:stored_collection_id).should be_true
    end

    it 'removes empty attributes from the list' do
      attrs = { title: '',
                filesize: [''],
                toc: nil,
                genre: [],
                stored_collection_id: '',
                description: ['a description'] }
      template = TuftsTemplate.new(attrs)
      result = template.attributes_to_update
      result.include?(:title).should be_false
      result.include?(:filesize).should be_false
      result.include?(:toc).should be_false
      result.include?(:genre).should be_false
      result.include?(:stored_collection_id).should be_false
      result.include?(:description).should be_true
    end
  end

  describe '#queue_jobs_to_apply_template' do
    it 'queues one job for each record' do
      user_id = 1
      record_ids = [1, 2, 3]
      attrs = { filesize: ['57 MB'] }
      template = TuftsTemplate.new(attrs)
      record_ids.each do |n|
        Job::ApplyTemplate.should_receive(:new).ordered.with(user_id, n, attrs).and_return("Job #{n}")
        Tufts.queue.should_receive(:push).ordered.with("Job #{n}")
      end

      template.queue_jobs_to_apply_template(user_id, record_ids)
    end

    it "doesn't queue any jobs if there is nothing to update" do
      attrs = { filesize: [''] }   # contains no data
      template = TuftsTemplate.new(attrs)

      error = "This method should not get called"
      Job::ApplyTemplate.stub(:new).and_raise(error + ' 1')
      Tufts.queue.stub(:push).and_raise(error + ' 2')

      template.queue_jobs_to_apply_template(1, [1, 2])
    end
  end

end
