module AuditLogService
  def self.log(who, what, message)
    logger.info("#{what} | #{message} | #{who}")
  end

  def self.logger
    @@logger ||= Logger.new(filename, 'monthly')
  end

  def self.filename
    Rails.root + 'log' + 'audit.log'
  end
end
