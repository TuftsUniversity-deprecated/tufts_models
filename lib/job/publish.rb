module Job
  class Publish

    attr_accessor :user_id, :record_id

    def initialize(user_id, record_id)
      self.user_id = user_id
      self.record_id = record_id
    end

    def queue_name
      :publish
    end

    def run
      record = ActiveFedora::Base.find(record_id, cast: true)
      record.publish!(user_id)
    end

  end
end
