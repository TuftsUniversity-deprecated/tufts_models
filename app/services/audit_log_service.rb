class AuditLogService < LogService
  def filename
    Rails.root + 'log' + 'audit.log'
  end
end
