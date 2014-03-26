class BatchNotRunnableException < StandardError; end

class Batch < ActiveRecord::Base
  # Note: This class is using Single Table Inheritance
  # http://api.rubyonrails.org/classes/ActiveRecord/Base.html#class-ActiveRecord::Base-label-Single+table+inheritance

  belongs_to :creator, class_name: "User"
  validates :creator, presence: true

  serialize :pids
  serialize :job_ids

  def jobs
    job_ids? ? job_ids.map{|job_id| Resque::Plugins::Status::Hash.get(job_id)} : []
  end

  def status
    order = {
      failed:    1,
      working:   2,
      queued:    3,
      completed: 4,
      killed:    5,
    }
    if jobs.any?(&:nil?)
      :not_available
    else
      jobs.min_by{|s| order[s.status]}.status
    end
  end

  def ready?
    raise NotImplementedError.new
  end

  def run
    raise NotImplementedError.new
  end
end
