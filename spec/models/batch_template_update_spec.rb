require 'spec_helper'

describe BatchTemplateUpdate do
  subject { FactoryGirl.build(:batch_template_update) }

  describe '.initialize' do
    subject { BatchTemplateUpdate.new(pids: input_pids) }

    context 'with non-draft pids' do
      let(:input_pids) { ['tufts:1', 'draft:2'] }
      let(:final_pids) { ['draft:1', 'draft:2'] }

      it 'converts pids to draft pids' do
        expect(subject.pids).to eq final_pids
      end
    end

    context 'with duplicate pid in different namespaces' do
      let(:input_pids) { ['tufts:1', 'draft:1'] }
      let(:final_pids) { ['draft:1'] }

      it 'removes duplicate pids' do
        expect(subject.pids).to eq final_pids
      end
    end
  end

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
