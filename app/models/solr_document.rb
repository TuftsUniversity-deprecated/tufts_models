# -*- encoding : utf-8 -*-
class SolrDocument 

  include Blacklight::Solr::Document

  # self.unique_key = 'id'
  
  use_extension FcrepoAdmin::SolrDocumentExtension

  def published?
    false
  end
end
