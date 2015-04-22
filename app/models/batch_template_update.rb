class BatchTemplateUpdate < Batch

  PRESERVE  = 'preserve'
  OVERWRITE = 'overwrite'

  def self.behavior_rules
    [PRESERVE, OVERWRITE]
  end

  validates :template_id, presence: true
  validates :pids,        presence: true
  validate  :template_not_empty
  validates :behavior, allow_blank: true,
        inclusion: { in: BatchTemplateUpdate.behavior_rules,
        message: "%{value} is not a valid template behavior" }


  def display_name
    "Update"
  end

  def run
    return false unless valid?
    attributes = TuftsTemplate.find(template_id).attributes_to_update
    return if attributes.empty?

    (ids = queue_jobs_to_apply_template(attributes)) && update_attribute(:job_ids, ids)
  end

  def overwrite?
    behavior == OVERWRITE
  end

  protected

    # This creates the job for the draft version of the pids passed in as record_ids
    # @param user_id
    # @param [Array<String>] record_ids a list of production pids
    # @param batch_id
    def queue_jobs_to_apply_template(attributes)
      pids.map do |record_id|
        Job::ApplyTemplate.create(user_id: creator.id, record_id: PidUtils.to_draft(record_id),
                                  attributes: attributes, batch_id: id)
      end
    end


    def template_not_empty
      if template_id? && TuftsTemplate.find(template_id).attributes_to_update.empty?
        errors.add(:base, "The selected template cannot be applied because it has no attributes filled out.")
      end
    end
end
