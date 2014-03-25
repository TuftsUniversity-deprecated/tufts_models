module Job
  class Publish
    include Resque::Plugins::Status

    def self.queue
      :publish
    end

    def self.create(options)
      required = [:record_id, :user_id]
      raise ArgumentError.new("Required keys: #{required}") if (required - options.keys).present?
      super
    end

    def perform
      record = ActiveFedora::Base.find(options['record_id'], cast: true)
      record.publish!(options['user_id'])
    end

  end
end
