class Sequence < ActiveRecord::Base
  def self.next_val options = {}
    namespace = options.fetch(:namespace, 'tufts')
    format = "#{namespace}:sd.%07d"
    seq = Sequence.first_or_create
    seq.with_lock do
      seq.value += 1
      seq.save!
    end
    sprintf(format, seq.value)
  end
end
