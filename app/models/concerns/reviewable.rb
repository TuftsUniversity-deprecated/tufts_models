module Reviewable
  extend ActiveSupport::Concern

  def self.batch_review_text
    'Batch Reviewed'
  end

  def clear_batch_review_text
    status_array = qrStatus.clone
    status_array.delete(Reviewable.batch_review_text)
    self.qrStatus = status_array
  end

  def reviewed?
    qrStatus.include?(Reviewable.batch_review_text)
  end

  def reviewed
    self.qrStatus = qrStatus + [Reviewable.batch_review_text]
  end

end
