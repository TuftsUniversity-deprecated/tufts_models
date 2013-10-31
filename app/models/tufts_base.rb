class TuftsBase < ActiveFedora::Base
  include Tufts::ModelMethods
  include Hydra::AccessControls::Permissions
  include AttachedFiles
  
  # Uses the Hydra Rights Metadata Schema for tracking access permissions & copyright
  has_metadata "rightsMetadata", type: Hydra::Datastream::RightsMetadata

  belongs_to :ead, :property => :has_description

  # Tufts specific needed metadata streams
  has_metadata "DCA-META", type: TuftsDcaMeta
  has_metadata "DC-DETAIL-META", type: TuftsDcDetailed
  has_metadata "DCA-ADMIN", type: DcaAdmin
  has_metadata "audit_log", type: Audit

  attr_accessor :push_production, :working_user

  before_save do
    self.edited_at = DateTime.now
    self.admin.published_at = edited_at if push_production
    if content_will_update 
      self.audit(working_user, "Content updated: #{content_will_update}")
      self.content_will_update = nil
    elsif metadata_streams.any? { |ds| ds.changed? }
      self.audit(working_user, "Metadata updated #{metadata_streams.select { |ds| ds.changed? }.map{ |ds| ds.dsid}.join(', ')}")
    end
  end

  #MK 2011-04-13 - Are we really going to need to access FILE-META from FILE-META.  I'm guessing
  # not.
  has_metadata :name => "FILE-META", :type => TuftsFileMeta


  validates :title, :presence => true
  validate :displays_valid
  
  has_attributes :identifier, :creator, :description, :publisher, :source, 
                 :date_created, :date_issued, :date_available, :type,
                 :format, :extent,  :persname, :corpname, :geogname,
                 :subject, :genre, :rights, :bibliographic_citation,
                 :temporal, :funder, :resolution, :bitdepth,
                 :colorspace, :filesize, datastream: 'DCA-META', multiple: true
  has_attributes :title, datastream: 'DCA-META', multiple: false

  has_attributes :alternative, :contributor, :abstract, :toc,
                 :date, :date_copyrighted, :date_submitted,
                 :date_accepted, :date_modified, :language, :medium,
                 :provenance, :access_rights, :rights_holder,
                 :license, :replaces, :isReplacedBy, :hasFormat,
                 :isFormatOf, :hasPart, :isPartOf, :accrualPolicy,
                 :audience, :references, :spatial, datastream: 'DC-DETAIL-META', multiple: true

  has_attributes :published_at, :edited_at, datastream: 'DCA-ADMIN', multiple: false
  has_attributes :steward, :name, :comment, :displays, :retentionPeriod, :embargo,
                 :status, :startDate, :expDate, :qrStatus, :rejectionReason, :note,
                 datastream: 'DCA-ADMIN', multiple: true

  def audit(user, what)
    return unless user
    audit_log.who = user.user_key
    audit_log.what = what
    audit_log.when = DateTime.now
  end


  def datastreams= (ds_data)
    ds_data.each do |dsid, val|
      next unless val.present?
      ds = datastreams[dsid]
      if ds.external?
        ds.dsLocation = val
      end
    end
  end

  # The list of all fields on this object that can be edited.
  # this governs the values that will be accepted from the form submission
  def terms_for_editing
    terms_for_display 
  end

  def terms_for_display
    descMetadata_display_fields + admin_display_fields
  end

  # The list of fields to edit from the DCA_META datastream
  def descMetadata_display_fields
    [:identifier, :title, :alternative, :creator, :contributor, :description, :abstract,
     :toc, :publisher, :source, :date, :date_created, :date_copyrighted,
     :date_submitted, :date_accepted, :date_issued, :date_available,
     :date_modified, :language, :type, :format, :extent, :medium, :persname, 
     :corpname, :geogname, :subject, :genre, :provenance, :rights,
     :access_rights, :rights_holder, :license, :replaces, :isReplacedBy,
     :hasFormat, :isFormatOf, :hasPart, :isPartOf, :accrualPolicy, :audience,
     :references, :spatial, :bibliographic_citation, :temporal, :funder,
     :resolution, :bitdepth, :colorspace, :filesize]
  end

  # The list of fields to edit from the DCA_ADMIN datastream
  def admin_display_fields
    admin.class.terminology.terms.keys  - [:admin, :published_at, :edited_at]
  end

  # a more idiomatic name for the DC-DETAIL-META datastream
  def detailMetadata
    self.DC_DETAIL_META
  end

  def descMetadata
    self.DCA_META
  end

  # a more idiomatic name for the DCA-ADMIN datastream
  def admin
    self.DCA_ADMIN
  end

  # return a list of external datastreams
  def external_datastreams
    datastreams.select { |name, ds| ds.external? }
  end

  # Test to see if the given field is required
  # @param [Symbol] key a field
  # @return [Boolean] is it required or not
  def required?(key)
    self.class.validators_on(key).any?{|v| v.kind_of? ActiveModel::Validations::PresenceValidator}
  end

  # Has this record been published yet?
  def published?
    published_at == edited_at
  end

  # Publish the record to the production fedora server
  def push_to_production!
    self.push_production = true
    if save
      # Now copy to prod
      # Rubydora::FedoraInvalidRequest
      foxml = self.inner_object.repository.export(pid: pid, context: 'archive')
      # You can't ingest to a pid that already exists, so try to purge it first
      production_fedora_connection.purge_object(pid: pid) rescue RestClient::ResourceNotFound
      production_fedora_connection.ingest(file: foxml)
    else
      # couldn't save
      raise "Unable to push to production"
    end
  end

  def production_fedora_connection
    @prod_repo ||= Rubydora.connect(ActiveFedora.data_production_credentials)
  end


  def to_solr(solr_doc=Hash.new, opts={})
    solr_doc = super
    create_facets solr_doc
    index_sort_fields solr_doc
    solr_doc
  end

  # override this method if you want to restrict the accepted formats to a particular mime-type
  # @param [String] dsid Datastream id
  # @param [String] type the content type to test
  def valid_type_for_datastream?(dsid, type)
    true
  end

  def displays_valid
    return unless displays.present?
    unless displays.all? {|d| %w(dl tisch aah perseus elections dark).include? d }
      errors.add(:displays, "must be in the list")
    end
  end
  
end


