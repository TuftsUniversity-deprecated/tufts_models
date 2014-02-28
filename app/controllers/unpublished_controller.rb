# -*- encoding : utf-8 -*-
require 'blacklight/catalog'

class UnpublishedController < CatalogController  

  UnpublishedController.solr_search_params_logic += [:only_changed_models, :non_templates]

  def only_changed_models(solr_parameters, user_parameters)
    solr_parameters[:fq] ||= []
    published = Solrizer.solr_name("published_at", :stored_sortable, type: :date)
    changed = Solrizer.solr_name("edited_at", :stored_sortable, type: :date)
    solr_parameters[:fq] << "{!frange l=0 incl=false}sub(#{changed},#{published})"
  end

  def non_templates(solr_parameters, user_parameters)
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << "NOT active_fedora_model_ssi:TuftsTemplate"
  end

end 
