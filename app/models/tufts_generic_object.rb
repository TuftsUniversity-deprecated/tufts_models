class TuftsGenericObject < ActiveFedora::Base

  include Hydra::ModelMethods
  include Tufts::ModelMethods
  include Hydra::ModelMixins::RightsMetadata

  # Uses the Hydra Rights Metadata Schema for tracking access permissions & copyright
  has_metadata "rightsMetadata", type: Hydra::Datastream::RightsMetadata

  # Tufts specific needed metadata streams
  has_metadata :name => "DCA-META", :type => TuftsDcaMeta

  has_metadata :name => "GENERIC-CONTENT", :type => TuftsGenericMeta

  def to_solr(solr_doc=Hash.new, opts={})
    super
    models = self.relationships(:has_model)
    unless models.include?("info:fedora/cm:Text.RCR") || models.include?("info:fedora/afmodel:TuftsRCR")
      create_facets solr_doc
    end

    index_sort_fields solr_doc

    index_fulltext solr_doc

    return solr_doc
  end

end
