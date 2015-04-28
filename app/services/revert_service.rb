class RevertService < WorkflowService

  # copy the published object over the draft
  def run
    pid = object.pid
    published_pid = PidUtils.to_published(pid)
    draft_pid = PidUtils.to_draft(pid)

    if object.class.exists? published_pid
      destroy_draft_version!
      FedoraObjectCopyService.new(object.class, from: published_pid, to: draft_pid).run
    end

    # ensure the solr index is up to date
    object.update_index

    audit('Reverted to published version')
  end
end

