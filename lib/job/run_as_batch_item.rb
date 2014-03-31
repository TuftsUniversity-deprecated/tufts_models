module Job
  module RunAsBatchItem

    # A wrapper for running a job as part of a batch of jobs.
    def run_as_batch_item(record_id, batch_id)
      record = ActiveFedora::Base.find(record_id, cast: true)
      record.batch_id = record.batch_id + [batch_id.to_s]
      yield record
    end

  end
end
