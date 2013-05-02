class CreateDerivatives

  def queue_name
    :derivatives
  end

  attr_accessor :record_id, :record

  def initialize(record_id)
    self.record_id = record_id
  end

  def run
    self.record = ActiveFeora::Base.find(record_id, cast: true)
    record.generate_derivatives
  end
end
