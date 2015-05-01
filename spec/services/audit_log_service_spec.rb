require 'spec_helper'

describe AuditLogService do
  describe ".log" do
    it "writes to the underlying logger" do
      expect_any_instance_of(Logger).to receive(:info).with("what | message | who")
      described_class.log('who', 'what', 'message')
    end
  end

  describe "#filename" do
    subject { described_class.instance.filename.to_s }
    it { is_expected.to end_with 'log/audit.log' }
  end
end
