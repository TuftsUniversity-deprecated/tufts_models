module Job
  class CreateDerivatives
    include Resque::Plugins::Status

    def self.queue
      :derivatives
    end

    attr_accessor :record_id, :record

    def self.create(options)
      raise ArgumentError.new("Must supply a record_id") if options[:record_id].blank?
      super
    end

    def perform
      record = ActiveFedora::Base.find(options['record_id'], cast: true)
      record.create_derivatives
      record.save(validate: false)
    end
  end
end
