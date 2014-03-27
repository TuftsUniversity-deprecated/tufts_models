module Job
  class ApplyTemplate
    include Resque::Plugins::Status
    include RunAsBatchItem

    def self.queue
      :templates
    end

    def self.create(options)
      required = [:record_id, :attributes, :user_id, :batch_id]
      raise ArgumentError.new("Required keys: #{required}") if (required - options.keys).present?
      super
    end

    def perform
      tick # give resque-status a chance to kill this

      run_as_batch_item(options['record_id'], options['batch_id']) do |record|
        record.apply_attributes(options['attributes'], options['user_id'])
      end
    end

  end
end
