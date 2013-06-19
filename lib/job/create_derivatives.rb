module Job
  class CreateDerivatives

    def queue_name
      :derivatives
    end

    attr_accessor :record_id, :record

    def initialize(record_id)
      self.record_id = record_id
    end

    def run
      self.record = ActiveFedora::Base.find(record_id, cast:true)
      record.create_derivatives
      record.save(validate: false)
    end
  end
end
