module BaseModel
  extend ActiveSupport::Concern
#TODO - decide what to do here  include Hydra::ModelMethods
  include Hydra::AccessControls::Permissions
  include Indexing

  included do
    validate :relationships_have_parseable_uris

    # Uses the Hydra Rights Metadata Schema for tracking access permissions & copyright
#    has_metadata "rightsMetadata", type: Hydra::Datastream::RightsMetadata

#TODO -- do we still need these or are they fedora 3 statements
    belongs_to :ead, :predicate => ActiveFedora::RDF::Fcrepo::RelsExt.hasDescription, :class_name=>'TuftsEAD'
    belongs_to :collection, :predicate => ActiveFedora::RDF::Fcrepo::RelsExt.isMemberOf, :class_name=>'TuftsEAD'

    # Tufts specific needed metadata streams
    contains "DCA-META", class_name: 'TuftsDcaMeta'
    contains "DC-DETAIL-META", class_name: 'TuftsDcDetailed'
    contains "DCA-ADMIN", class_name: 'DcaAdmin'

    attr_accessor :working_user, :publishing, :unpublishing, :reverting, :exporting

    before_save do
      self.edited_at = DateTime.now if update_edited_at?

      self.published_at = edited_at if publishing

      # Don't change existing OAI IDs, but for any objects with a display portal of 'dl', generate an OAI ID
      if displays.include?('dl') && !object_relations.has_predicate?(:oai_item_id)
        self.add_relationship(:oai_item_id, "oai:#{pid}", true)
        # we didn't use .serialize! here because it would mark the model as clean and then
        # never actually save to Fedora
        self.rels_ext.content = rels_ext.to_rels_ext
      end
    end

    before_save :update_audit_log

    def update_edited_at?
      !(reverting || exporting)
    end

    def self.valid_pid?(pid)
      pid.match(/^([A-Za-z0-9]|-|\.)+:(([A-Za-z0-9])|-|\.|~|_|(%[0-9A-F]{2}))+$/)
    end

    def update_audit_log
      if respond_to?(:content_will_update) && content_will_update
        self.audit(working_user, "Content updated: #{content_will_update}")
        self.content_will_update = nil
      elsif metadata_streams.any? { |ds| ds.changed? } && !publishing && !unpublishing
        self.audit(working_user, "Metadata updated: #{metadata_streams.select { |ds| ds.changed? }.map{ |ds| ds.dsid}.join(', ')}")
      end

    end

    property :identifier, delegate_to: 'DCA-META', multiple: true
    property :creator, delegate_to: 'DCA-META', multiple: true
    property :description, delegate_to: 'DCA-META', multiple: true
    property :publisher, delegate_to: 'DCA-META', multiple: true
    property :source, delegate_to: 'DCA-META', multiple: true
    property :date_created, delegate_to: 'DCA-META', multiple: true
    property :date_issued, delegate_to: 'DCA-META', multiple: true
    property :date_available, delegate_to: 'DCA-META', multiple: true
    property :type, delegate_to: 'DCA-META', multiple: true
    property :format, delegate_to: 'DCA-META', multiple: true
    property :extent, delegate_to: 'DCA-META', multiple: true
    property :persname, delegate_to: 'DCA-META', multiple: true
    property :corpname, delegate_to: 'DCA-META', multiple: true
    property :geogname, delegate_to: 'DCA-META', multiple: true
    property :subject, delegate_to: 'DCA-META', multiple: true
    property :genre, delegate_to: 'DCA-META', multiple: true
    property :rights, delegate_to: 'DCA-META', multiple: true
    property :bibliographic_citation, delegate_to: 'DCA-META', multiple: true
    property :temporal, delegate_to: 'DCA-META', multiple: true
    property :funder, delegate_to: 'DCA-META', multiple: true
    property :resolution, delegate_to: 'DCA-META', multiple: true
    property :bitdepth, delegate_to: 'DCA-META', multiple: true
    property :colorspace, delegate_to: 'DCA-META', multiple: true
    property :filesize, delegate_to: 'DCA-META', multiple: true

    property :title, delegate_to: 'DCA-META', multiple: false

    property :alternative, delegate_to: 'DCA-DETAIL-META', multiple: true
    property :contributor, delegate_to: 'DCA-DETAIL-META', multiple: true
    property :abstract, delegate_to: 'DCA-DETAIL-META', multiple: true
    property :toc, delegate_to: 'DCA-DETAIL-META', multiple: true
    property :date, delegate_to: 'DCA-DETAIL-META', multiple: true
    property :date_copyrighted, delegate_to: 'DCA-DETAIL-META', multiple: true
    property :date_submitted, delegate_to: 'DCA-DETAIL-META', multiple: true
    property :date_accepted, delegate_to: 'DCA-DETAIL-META', multiple: true
    property :date_modified, delegate_to: 'DCA-DETAIL-META', multiple: true
    property :language, delegate_to: 'DCA-DETAIL-META', multiple: true
    property :medium, delegate_to: 'DCA-DETAIL-META', multiple: true
    property :provenance, delegate_to: 'DCA-DETAIL-META', multiple: true
    property :access_rights, delegate_to: 'DCA-DETAIL-META', multiple: true
    property :rights_holder, delegate_to: 'DCA-DETAIL-META', multiple: true
    property :license, delegate_to: 'DCA-DETAIL-META', multiple: true
    property :replaces, delegate_to: 'DCA-DETAIL-META', multiple: true
    property :isReplacedBy, delegate_to: 'DCA-DETAIL-META', multiple: true
    property :hasFormat, delegate_to: 'DCA-DETAIL-META', multiple: true
    property :isFormatOf, delegate_to: 'DCA-DETAIL-META', multiple: true
    property :hasPart, delegate_to: 'DCA-DETAIL-META', multiple: true
    property :isPartOf, delegate_to: 'DCA-DETAIL-META', multiple: true
    property :accrualPolicy, delegate_to: 'DCA-DETAIL-META', multiple: true
    property :audience, delegate_to: 'DCA-DETAIL-META', multiple: true
    property :references, delegate_to: 'DCA-DETAIL-META', multiple: true
    property :spatial, delegate_to: 'DCA-DETAIL-META', multiple: true

    property :published_at, delegate_to: 'DCA-ADMIN', multiple: false
    property :edited_at, delegate_to: 'DCA-ADMIN', multiple: false
    property :createdby, delegate_to: 'DCA-ADMIN', multiple: false
    property :creatordept, delegate_to: 'DCA-ADMIN', multiple: false

    property :steward, delegate_to: 'DCA-ADMIN', multiple: true
    property :name, delegate_to: 'DCA-ADMIN', multiple: true
    property :comment, delegate_to: 'DCA-ADMIN', multiple: true
    property :displays, delegate_to: 'DCA-ADMIN', multiple: true
    property :retentionPeriod, delegate_to: 'DCA-ADMIN', multiple: true
    property :embargo, delegate_to: 'DCA-ADMIN', multiple: true
    property :status, delegate_to: 'DCA-ADMIN', multiple: true
    property :startDate, delegate_to: 'DCA-ADMIN', multiple: true
    property :expDate, delegate_to: 'DCA-ADMIN', multiple: true
    property :qrStatus, delegate_to: 'DCA-ADMIN', multiple: true
    property :rejectionReason, delegate_to: 'DCA-ADMIN', multiple: true
    property :note, delegate_to: 'DCA-ADMIN', multiple: true

  end  # end "included" section


  # If the ead this object belongs to doesn't exist, ActiveFedora won't load it.
  # We give access to that value manually, here.
  def stored_collection_id
    is_member_of = object_relations.uri_predicate(:is_member_of)
    has_description = object_relations.uri_predicate(:has_description)
    collection_id ||
      ead_id ||
      object_relations.relationships[is_member_of].first.try{|m| m.gsub("info:fedora/", "")} ||
      object_relations.relationships[has_description].first.try{|m| m.gsub("info:fedora/", "")}
  end

  def stored_collection_id=(pid)
    self.collection_id = pid
    self.ead_id = pid
  end

  def relationship_attributes
    rels = []
    rels_ext_edit_fields.each do |rel|
      predicate = object_relations.uri_predicate(rel)
      uris = object_relations.relationships[predicate]
      unless uris.empty?
        rel_pids = uris.map {|uri| uri.gsub("info:fedora/", "")}
        rel_pids.each do |pid|
          builder = RelationshipBuilder.new(rel, pid)
          rels << builder
        end
      end
    end
    # Include invalid relationships for displaying errors on the edit form
    rels = rels + @invalid_rels unless @invalid_rels.blank?
    rels
  end

  # Set rels-ext according to what the user entered on the edit form
  def relationship_attributes=(attrs)

    # Don't try to set relationships that fail validation
    validate_relationships(attrs)
    @invalid_rels.each do |rel|
      attrs = attrs.reject{|a| a['relationship_name'] == rel.relationship_name && a['relationship_value'] == rel.relationship_value }
    end

    # Clear out old relationships
    rels_ext_edit_fields.each do |predicate_name|
      pred = ActiveFedora::Predicates.find_graph_predicate(predicate_name)
      clear_relationship(pred)
    end

    attrs = attrs.reject{|e| e['relationship_name'].blank? || e['relationship_value'].blank? }

    # Only accept fields that users are allowed to edit
    attrs = attrs.reject{|e| !rels_ext_edit_fields.include?(e['relationship_name'].to_sym) }

    attrs.each do |attr|
      predicate_name = attr['relationship_name'].to_sym
      pred = ActiveFedora::Predicates.find_graph_predicate(predicate_name)
      add_relationship(pred, 'info:fedora/' + attr['relationship_value'])
    end
    self.rels_ext.content = rels_ext.to_rels_ext()
  end

  # The way validation normally works, the value of an
  # attribute is set first, and then it is validated.  But we
  # have a case where we can't set the value first because
  # setting the value raises an error.
  # (When there is a PID that won't parse into a URI, calling
  # relationship_attributes= raises URI::InvalidURIError)
  # Later when validation is called, all errors are cleared
  # at the beginning of validation, so the URI::InvalidURIError
  # messages are lost.
  #
  # This is a kludge to keep track of those invalid inputs
  # and their corresponding error messages so that they can
  # be displayed to the user on the edit form.
  #
  def validate_relationships(attrs)
    @invalid_rels = []
    @invalid_rels_errors = []

    attrs.each do |rel|
      begin
        URI.parse rel['relationship_value']
      rescue URI::InvalidURIError
        @invalid_rels << RelationshipBuilder.new(rel['relationship_name'], rel['relationship_value'])
        @invalid_rels_errors << "Invalid relationship: \"#{rel['relationship_name'].to_s.titleize}\" : \"#{rel['relationship_value']}\""
      end
    end
  end
  protected :validate_relationships

  def relationships_have_parseable_uris
    @invalid_rels_errors ||= []
    @invalid_rels_errors.each do |err|
      errors.add(:base, err)
    end
  end
  protected :relationships_have_parseable_uris

  def audit(user, what)
    user_label = user ? user.user_key : 'unknown'
    AuditLogService.log(user_label, pid, what)
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

  def rels_ext_edit_fields
    [:has_equivalent,
     :is_annotation_of, :has_annotation,
     :is_constituent_of, :has_constituent,
     :is_dependent_of, :has_dependent,
     :is_derivation_of, :has_derivation,
     :is_description_of, :has_description,
     :is_member_of, :has_member,
     :is_member_of_collection, :has_collection_member,
     :is_metadata_for, :has_metadata,
     :is_part_of, :has_part,
     :is_subset_of, :has_subset]
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
    admin.class.terminology.terms.keys  - [:admin, :published_at, :edited_at, :template_name, :batch_id]
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

  # override this method if you want to restrict the accepted formats to a particular mime-type
  # @param [String] dsid Datastream id
  # @param [String] type the content type to test
  def valid_type_for_datastream?(dsid, type)
    true
  end

  def has_thumbnail?
    false
  end
end
