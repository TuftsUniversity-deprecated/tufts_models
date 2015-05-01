class LogService
  include Singleton
  def self.log(who, what, message)
    instance.logger.info("#{what} | #{message} | #{who}")
  end

  def logger
    @logger ||= Logger.new(filename, 'monthly')
  end

  def filename
    raise NotImplementedError("implement this in a subclass")
  end
end

