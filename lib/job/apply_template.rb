module Job
  class ApplyTemplate
    include Resque::Plugins::Status

    def self.queue
      :templates
    end

    def self.create(options)
      required = [:record_id, :attributes, :user_id]
      raise ArgumentError.new("Required keys: #{required}") if (required - options.keys).present?
      super
    end

    def perform
      tick # give resque-status a chance to kill this
      record = ActiveFedora::Base.find(options['record_id'], cast: true)
      record.apply_attributes(options['attributes'], options['user_id'])
    end

  end
end
