module Job
  class Revert
    include Resque::Plugins::Status
    include RunAsBatchItem

    def self.queue
      :revert
    end

    def self.create(options)
      required = [:record_id, :user_id, :batch_id]
      raise ArgumentError.new("Required keys: #{required}") if (required - options.keys).present?
      super
    end

    def perform
      tick # give resque-status a chance to kill this

      TuftsBase.revert_to_production(options['record_id'])
      run_as_batch_item(options['record_id'], options['batch_id']) do |record|
        record.save!
      end
    end

  end
end
