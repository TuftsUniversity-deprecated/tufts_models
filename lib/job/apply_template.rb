module Job
  class ApplyTemplate

    attr_accessor :user_id, :record_id, :attributes

    def initialize(user_id, record_id, attributes)
      self.user_id = user_id
      self.record_id = record_id
      self.attributes = attributes
    end

    def queue_name
      :templates
    end

    def run
      record = ActiveFedora::Base.find(record_id, cast: true)
      record.apply_attributes(attributes, user_id)
    end

  end
end
