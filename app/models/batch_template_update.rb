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
    (ids = TuftsTemplate.find(template_id).queue_jobs_to_apply_template(creator.id, pids, id)) &&
      update_attribute(:job_ids, ids)
  end

  def overwrite?
    behavior == OVERWRITE
  end

  protected

  def template_not_empty
    if template_id? && TuftsTemplate.find(template_id).attributes_to_update.empty?
      errors.add(:base, "The selected template cannot be applied because it has no attributes filled out.")
    end
  end
end
