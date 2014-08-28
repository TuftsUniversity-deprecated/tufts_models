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

  def to_solr(solr_doc=Hash.new)
    super.tap do |solr_doc|
      solr_doc['is_root_bsi'] = root?
    end
  end

  # You must override this method to use this module
  # We'll just return false because it seems like a reasonable default
  def root?
    false
  end
end
