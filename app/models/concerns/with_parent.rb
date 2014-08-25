module WithParent
  extend ActiveSupport::Concern

  def parent
    ActiveFedora::Base.where(member_ids_ssim: self.id).first
  end

  def ancestors_and_self(acc=[])
    if root?
      acc
    else
      self.parent.ancestors_and_self([self] + acc)
    end
  end

  # You must override this method to use this module
  def root?
    raise NotImplementedError
  end
end
