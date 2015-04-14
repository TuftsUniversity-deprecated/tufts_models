class PidUtils

  def self.draft_namespace
    'draft'
  end

  def self.published_namespace
    'tufts'
  end

  def self.to_draft(pid)
    "#{draft_namespace}:#{stripped_pid(pid)}"
  end
  
  def self.to_published(pid)
    "#{published_namespace}:#{stripped_pid(pid)}"
  end

  def self.stripped_pid(pid)
    pid.sub(/.+:(.+)$/, '\1')
  end

end
