# -*- encoding : utf-8 -*-
module Tufts::SolrDocument
  def reviewed?
    Array(self['qrStatus_tesim']).include?(Reviewable.batch_review_text)
  end

  def reviewable?
    !template? && !reviewed? && in_a_batch?
  end

  def in_a_batch?
    !Array(self['batch_id_ssim']).empty?
  end

  def published?
    self[Solrizer.solr_name("edited_at", :stored_sortable, type: :date)] ==
      self[Solrizer.solr_name("published_at", :stored_sortable, type: :date)]
  end

  def publishable?
    !published? && !template?
  end

  def template?
    self['active_fedora_model_ssi'] == 'TuftsTemplate'
  end

  def image?
    self['active_fedora_model_ssi'] == 'TuftsImage'
  end

  def collection?
    self['active_fedora_model_ssi'] == 'CuratedCollection'
  end

  def preview_fedora_path
    Settings.preview_fedora_url + "/objects/#{id}"
  end

  def preview_dl_path
    return nil if template?
    if self['displays_ssim'].blank? || self['displays_ssim'] == [''] || self['displays_ssim'].include?('dl')
      Settings.preview_dl_url + "/catalog/#{id}"
    else
      return nil
    end
  end

  def to_model
    if collection?
      m = ActiveFedora::Base.load_instance_from_solr(id, self)
      m.class == ActiveFedora::Base ? self : m
    else
      self
    end
  end

end
