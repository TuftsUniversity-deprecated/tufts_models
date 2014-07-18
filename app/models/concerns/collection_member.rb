module CollectionMember
  extend ActiveSupport::Concern

  included do
    before_destroy :remove_from_collections
  end

  def remove_from_collections
    CuratedCollection.where(member_ids_ssim: pid).each do |collection|
      collection.member_ids = collection.member_ids.reject { |member_id| member_id == pid }
      collection.save!
    end
  end

end

