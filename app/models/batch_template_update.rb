class BatchTemplateUpdate < Batch
  validates :template_id, presence: true
  validates :pids,        presence: true
  validate :template_not_empty

  serialize :pids

  def ready?
    valid?
  end

  def run
    ready? && TuftsTemplate.find(template_id).queue_jobs_to_apply_template(creator.id, pids)
  end

  protected

  def template_not_empty
    if template_id? && TuftsTemplate.find(template_id).attributes_to_update.empty?
      errors.add(:base, "The selected template cannot be applied because it has no attributes filled out.")
    end
  end
end
