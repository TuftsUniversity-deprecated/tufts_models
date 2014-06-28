require 'spec_helper'

describe TuftsTemplate do

  it 'most metadata attributes are not required' do
    subject.required?(:title).should be_falsey
    subject.required?(:displays).should be_falsey
  end

  it 'has a unique pid namespace' do
    template = TuftsTemplate.new(template_name: 'Template #1')
    template.save
    template.pid.should match /^template:/
  end

  describe 'template_name attribute' do
    it 'getter and setter methods exist' do
      subject.template_name = 'Title #1'
      subject.template_name.should == 'Title #1'
    end

    it 'is required' do
      subject.required?(:template_name).should be_truthy
    end
  end

  describe 'publishing' do
    it 'cannot be pushed to the production environment' do
      expect{ subject.publish! }.to raise_error(UnpublishableModelError)
      expect{ subject.push_to_production! }.to raise_error(UnpublishableModelError)
    end

    it 'is never published' do
      subject.published?.should be_falsey
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
      template.terms_for_editing.include?(:title).should be_truthy
      template.terms_for_editing.include?(:filesize).should be_truthy
      template.terms_for_editing.include?(:discover_users).should be_falsey

      # Any attributes that aren't in terms_for_editing should
      # not be included in our result
      result = template.attributes_to_update
      result.class.should == Hash
      result.include?(:title).should be_truthy
      result.include?(:filesize).should be_truthy
      result.include?(:discover_users).should be_falsey
    end

    it 'removes empty attributes from the list' do
      attrs = { title: '',
                filesize: [''],
                toc: nil,
                genre: [],
                relationship_attributes: [],
                description: ['a description'] }
      template = TuftsTemplate.new(attrs)
      result = template.attributes_to_update
      result.include?(:title).should be_falsey
      result.include?(:filesize).should be_falsey
      result.include?(:toc).should be_falsey
      result.include?(:genre).should be_falsey
      result.include?(:relationship_attributes).should be_falsey
      result.include?(:description).should be_truthy
    end

    it 'contains rels-ext attributes' do
      template = TuftsTemplate.new
      pid = 'pid:123'
      template.add_relationship(:is_part_of, "info:fedora/#{pid}")
      attrs = template.attributes_to_update
      expect(attrs[:relationship_attributes].length).to eq 1
      relation = attrs[:relationship_attributes].first
      expect(relation['relationship_name']).to eq(:is_part_of)
      expect(relation['relationship_value']).to eq pid
    end
  end

  describe '#queue_jobs_to_apply_template' do
    it 'queues one job for each record' do
      user_id = 1
      record_ids = [1, 2, 3]
      attrs = { filesize: ['57 MB'] }
      batch_id = '10'
      template = TuftsTemplate.new(attrs)
      record_ids.each do |n|
        Job::ApplyTemplate.should_receive(:create).ordered.with(user_id: user_id, record_id: n, attributes: attrs, batch_id: batch_id).and_return("Job #{n}")
      end

      template.queue_jobs_to_apply_template(user_id, record_ids, batch_id)
    end

    it "doesn't queue any jobs if there is nothing to update" do
      attrs = { filesize: [''] }   # contains no data
      template = TuftsTemplate.new(attrs)

      error = "This method should not get called"
      Job::ApplyTemplate.stub(:create).and_raise(error + ' 1')

      template.queue_jobs_to_apply_template(1, [1, 2], 10)
    end

    it "returns a list of job ids" do
      user_id = 1
      record_ids = [1, 2, 3]
      attrs = { filesize: ['57 MB'] }
      template = TuftsTemplate.new(attrs)
      allow(Job::ApplyTemplate).to receive(:create).and_return(:a, :b, :c)

      expect(template.queue_jobs_to_apply_template(user_id, record_ids, 10)).to eq [:a, :b, :c]
    end
  end

  describe "#apply_attributes" do
    it 'raises an error' do
      expect{subject.apply_attributes(description: 'new desc')}.to raise_exception(CannotApplyTemplateError)
    end
  end

  describe 'deleted templates' do
    before do
      TuftsTemplate.delete_all
      subject.template_name = 'Name'
      subject.save!
      @deleted_template = FactoryGirl.create(:tufts_template)
      @deleted_template.purge!
    end

    it "don't appear in the list of all active templates" do
      expect(subject.state).to eq 'A'
      expect(@deleted_template.state).to eq 'D'
      expect(TuftsTemplate.count).to eq 2
      expect(TuftsTemplate.active).to eq [subject]
    end
  end
end
