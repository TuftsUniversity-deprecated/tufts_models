class BatchNotRunnableException < StandardError; end

class Batch < ActiveRecord::Base
  # Note: This class is using Single Table Inheritance
  # http://api.rubyonrails.org/classes/ActiveRecord/Base.html#class-ActiveRecord::Base-label-Single+table+inheritance
  belongs_to :creator, class_name: "User"

  validates :creator, presence: true

  def ready?
    raise NotImplementedError.new
  end

  def run
    raise NotImplementedError.new
  end
end
