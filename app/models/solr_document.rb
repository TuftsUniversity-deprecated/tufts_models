# -*- encoding : utf-8 -*-
class SolrDocument 

  include Blacklight::Solr::Document

  # self.unique_key = 'id'
  
  use_extension FcrepoAdmin::SolrDocumentExtension

  def published?
    self[Solrizer.solr_name("edited_at", :stored_sortable, type: :date)] == 
      self[Solrizer.solr_name("published_at", :stored_sortable, type: :date)]
  end

  def preview_path
    if self['displays_ssi'].blank? || self['displays_ssi'] == 'dl'
      Settings.preview_dl_url + "/catalog/#{id}" 
    else
      Settings.preview_fedora_url + "/objects/#{id}" 
    end
  end
end
