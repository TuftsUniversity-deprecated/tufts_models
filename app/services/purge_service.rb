class PurgeService < WorkflowService
  def run
    if destroy_published_version!
      audit("Purged published version")
    end

    if destroy_draft_version!
      audit("Purged draft version")
    end
  end
end
