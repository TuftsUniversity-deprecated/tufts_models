class TuftsBase < ActiveFedora::Base

  include Hydra::ModelMethods
  include Tufts::ModelMethods
  include Hydra::ModelMixins::RightsMetadata
  
  # Uses the Hydra Rights Metadata Schema for tracking access permissions & copyright
  has_metadata "rightsMetadata", type: Hydra::Datastream::RightsMetadata

  # Tufts specific needed metadata streams
  has_metadata :name => "DCA-META", :type => TuftsDcaMeta

  validates_presence_of :title#, :creator, :description
  
  delegate_to "DCA-META", [:title, :creator, :source2, :description, :dateCreated, :dateAvailable, 
                           :dateIssued, :identifier, :rights, :bibliographicCitation, :publisher,
                           :type2, :format2, :extent, :persname, :corpname, :geogname, :genre,
                           :subject, :funder, :temporal, :resolution, :bitDepth, :colorSpace, 
                           :filesize]

  def terms_for_editing
    terms_for_display 
  end

  def terms_for_display
    self.descMetadata.class.terminology.terms.keys - [:root]
  end

  def descMetadata
    self.DCA_META
  end

  def required?(key)
    self.class.validators_on(key).any?{|v| v.kind_of? ActiveModel::Validations::PresenceValidator}
  end


  #MK 2011-04-13 - Are we really going to need to access FILE-META from FILE-META.  I'm guessing
  # not.
  has_metadata :name => "FILE-META", :type => TuftsFileMeta

  def to_solr(solr_doc=Hash.new, opts={})
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


