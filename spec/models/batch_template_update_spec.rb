require 'spec_helper'

describe BatchTemplateUpdate do
  subject { FactoryGirl.build(:batch_template_update) }

  it "requires a template_id" do
    subject.template_id = nil
    expect(subject.valid?).to be_falsey
  end

  it "requires the template to actually change something" do
    template = FactoryGirl.create(:tufts_template, title: nil)
    expect(template.attributes_to_update).to be_empty
    batch = FactoryGirl.build(:batch_template_update, template_id: template.id)
    expect(batch.valid?).to be_falsey
  end

  it "requires pids" do
    subject.pids = nil
    expect(subject.valid?).to be_falsey
  end

  it 'starts processing and saves the job UUIDs' do
    template = TuftsTemplate.find(subject.template_id)
    allow(TuftsTemplate).to receive(:find).with(template.id) { template }
    job_ids = [1, 2]
    subject.save

    expect(template).to receive(:queue_jobs_to_apply_template).with(subject.creator.id, subject.pids, subject.id) { job_ids }
    subject.run
    expect(subject.job_ids).to eq job_ids
    template.delete
  end

  it "only runs when it's valid" do
    b = BatchTemplateUpdate.new
    expect(b.valid?).to be_falsey
    expect(b.run).to be_falsey
  end

  describe 'template behavior rules:' do
    it 'has a list of valid behavior rules' do
      expect(BatchTemplateUpdate.behavior_rules).to eq [BatchTemplateUpdate::PRESERVE, BatchTemplateUpdate::OVERWRITE]
    end

    it 'validates behavior with a white list of rules' do
      valid_rules = [BatchTemplateUpdate::PRESERVE, BatchTemplateUpdate::OVERWRITE]

      b = FactoryGirl.build(:batch_template_update)
      valid_rules.each do |rule|
        b.behavior = rule
        expect(b.valid?).to be_truthy
      end

      b.behavior = 'something invalid'
      expect(b.valid?).to be_falsey

      b.behavior = nil
      expect(b.valid?).to be_truthy
    end

    it 'knows if the template will overwrite existing values' do
      b = FactoryGirl.build(:batch_template_update)
      b.behavior = BatchTemplateUpdate::PRESERVE
      expect(b.overwrite?).to be_falsey
      b.behavior = BatchTemplateUpdate::OVERWRITE
      expect(b.overwrite?).to be_truthy
    end
  end
end
