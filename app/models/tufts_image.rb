class TuftsImage < ActiveFedora::Base

  include Hydra::ModelMethods
  include Tufts::ModelMethods
  include Hydra::ModelMixins::RightsMetadata

  # Uses the Hydra Rights Metadata Schema for tracking access permissions & copyright
  has_metadata "rightsMetadata", type: Hydra::Datastream::RightsMetadata

  # Tufts specific needed metadata streams
  has_metadata :name => "DCA-META", :type => TuftsDcaMeta

  #MK 2011-04-13 - Are we really going to need to access FILE-META from FILE-META.  I'm guessing
  # not.
  has_metadata :name => "FILE-META", :type => TuftsFileMeta

  def to_solr(solr_doc=Hash.new, opts={})
    #prefilter perseus and art history objects
    if ['perseus','aah'].any? { |word| pid.include?(word) }
      return solr_doc
    end

    #also filter year book pages and election images
    if ['tufts:UP150','tufts:MS115.001'].any? { |word| pid.starts_with?(word) }
          return solr_doc
    end

    solr_doc = super
    models = self.relationships(:has_model)
    unless models.include?("info:fedora/cm:Text.RCR") || models.include?("info:fedora/afmodel:TuftsRCR")
      create_facets solr_doc
    end

    index_sort_fields solr_doc

    index_fulltext solr_doc

    return solr_doc
  end
end
