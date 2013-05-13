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
      self.record = ActiveFedora::Base.load_instance_from_solr(record_id)
      record.create_derivatives
    end
  end
end
