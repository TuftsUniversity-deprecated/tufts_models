class TemplatesController < CatalogController

  # Since TuftsTemplates behave just like other fedora
  # objects, most of the template actions are handled by
  # either the CatalogController or the RecordsController.

  TemplatesController.solr_search_params_logic += [:only_templates]

  def only_templates(solr_parameters, user_parameters)
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << "active_fedora_model_ssi:TuftsTemplate"
  end

end
