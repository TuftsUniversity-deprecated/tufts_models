class Sequence < ActiveRecord::Base
  def self.next_val options = {}
    namespace = options.fetch(:namespace, 'tufts')
    format = options.fetch(:format, "#{namespace}:sd.%07d")
    seq = Sequence.find_or_create_by(scope: options[:scope])
    seq.with_lock do
      seq.value += 1
      seq.save!
    end
    sprintf(format, seq.value)
  end
end
