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

      published_pid = PidUtils.to_published(options['record_id'])

      begin
        run_as_batch_item(published_pid, options['batch_id']) do |record|
          record.save! # batch_id gets set on the object here, so we need to save it first
          record.revert!
        end
      rescue ActiveFedora::ObjectNotFoundError => ex
        # nothing here. It's ok to try to revert a pid that doesn't exist.
      end
    end

  end
end
