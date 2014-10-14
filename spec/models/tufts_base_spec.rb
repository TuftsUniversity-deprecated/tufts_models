require 'spec_helper'

describe TuftsBase do

  it 'knows which fields to display for admin metadata' do
    expect(subject.admin_display_fields).to eq [:steward, :name, :comment, :retentionPeriod, :displays, :embargo, :status, :startDate, :expDate, :qrStatus, :rejectionReason, :note, :createdby, :creatordept]
  end

  it 'batch_id is not editable by users' do
    expect(subject.terms_for_editing.include?(:batch_id)).to be false
  end

  describe 'required fields:' do
    it 'requires a title' do
      expect(subject.required?(:title)).to be true
    end

    it 'requires displays' do
      expect(subject.required?(:displays)).to be true
    end
  end

  describe ".valid_pid?" do
    it "tells you if a pid is valid" do
      expect(TuftsBase.valid_pid?('tufts:1')).to be_truthy
      expect(TuftsBase.valid_pid?('demo:FLORA:01.01')).to be_falsy
    end
  end

  describe "to_solr" do
    describe "when not saved" do
      before do
        allow(subject).to receive(:pid).and_return('changeme:999')
      end

      describe "subject field" do
        it "should save both" do
          subject.subject = ["subject1"]
          subject.funder = ["subject2"]
          solr_doc = subject.to_solr
          expect(solr_doc["subject_tesim"]).to eq ["subject1"]
          expect(solr_doc["funder_tesim"]).to eq ["subject2"]
          # TODO is this right? Presumably this is for the facet
          expect(solr_doc["subject_sim"]).to eq ["Subject1"]
        end
      end

      describe "displays" do
        it "should save it" do
          subject.displays = ["dl"]
          solr_doc = subject.to_solr
          expect(solr_doc['displays_ssim']).to eq ['dl']
        end
      end

      describe "title" do
        it "should be searchable and facetable" do
          subject.title = "My title"
          solr_doc = subject.to_solr
          expect(solr_doc['title_si']).to eq 'My title'
          expect(solr_doc['title_tesim']).to eq ['My title']
        end
      end

      describe "contributor added" do
        it "should save it" do
          subject.contributor = ["Michael Jackson"]
          solr_doc = subject.to_solr
          expect(solr_doc['names_sim']).to eq ['Michael Jackson']
        end
      end
    end

    describe "date added" do
      before do
        subject.save(validate: false)
        @solr_doc = subject.to_solr
      end
      it "should be sortable" do
        expect(@solr_doc['system_create_dtsi']).to_not be_nil
      end
    end
  end

  describe "displays" do
    it "should only allow one of the approved values" do
      subject.title = 'test title' #make it valid
      subject.displays = ['dl']
      expect(subject).to be_valid
      subject.displays = ['tisch']
      expect(subject).to be_valid
      subject.displays = ['aah']
      expect(subject).to be_valid
      subject.displays = ['perseus']
      expect(subject).to be_valid
      subject.displays = ['elections']
      expect(subject).to be_valid
      subject.displays = ['dark']
      expect(subject).to be_valid
      subject.displays = ['tdil']
      expect(subject).to be_valid
      subject.displays = ['fake']
      expect(subject).to_not be_valid
    end
  end

  describe 'namespace' do
    it 'correctly prefixes DC terms' do
      dc_attributes = [:title, :creator, :source, :description,
                       :date_created, :date_available, :date_issued,
                       :identifier, :rights, :bibliographic_citation,
                       :publisher, :type, :format, :extent, :temporal]
      dc_attributes.each do |attrib|
        dsid = subject.class.defined_attributes[attrib].dsid
        namespace = subject.datastreams[dsid].class.terminology.terms[attrib].namespace_prefix
        expect(namespace).to eq('dc'),
         "wrong namespace for :#{attrib.to_s}\n  expected: 'dc'\n       got: '#{namespace}"
      end
    end

    it 'correctly prefixes DCADESC terms' do
      desc_attributes = [:persname, :corpname, :geogname, :genre, :subject, :funder]
      desc_attributes.each do |attrib|
        dsid = subject.class.defined_attributes[attrib].dsid
        namespace = subject.datastreams[dsid].class.terminology.terms[attrib].namespace_prefix
        expect(namespace).to eq('dcadesc'),
                             "wrong namespace for :#{attrib.to_s}\n  expected: 'dcadesc'\n       got: '#{namespace}"
      end
    end

    it 'correctly prefixes DCATECH terms' do
      tech_attributes = [:resolution, :bitdepth, :colorspace, :filesize]
      tech_attributes.each do |attrib|
        dsid = subject.class.defined_attributes[attrib].dsid
        namespace = subject.datastreams[dsid].class.terminology.terms[attrib].namespace_prefix
        expect(namespace).to eq('dcatech'),
                             "wrong namespace for :#{attrib.to_s}\n  expected: 'dcatech'\n       got: '#{namespace}"
      end
    end

    it 'correctly prefixes DCAADMIN terms' do
      admin_attributes = [:steward, :retentionPeriod, :displays,
                       :embargo, :status, :startDate, :expDate, :qrStatus,
                       :rejectionReason, :note, :createdby, :published_at, :edited_at,
                       :creatordept, :batch_id]
      admin_attributes.each do |attrib|
        dsid = subject.class.defined_attributes[attrib].dsid
        namespace = subject.datastreams[dsid].class.terminology.terms[attrib].namespace_prefix
        expect(namespace).to eq('local'),
                             "wrong namespace for :#{attrib.to_s}\n  expected: 'local'\n       got: '#{namespace}"
      end
    end

    it 'correctly prefixes DCMITYPE terms' do
      dcmi_attributes = [:name, :comment]
      dcmi_attributes.each do |attrib|
        dsid = subject.class.defined_attributes[attrib].dsid
        namespace = subject.datastreams[dsid].class.terminology.terms[attrib].namespace_prefix
        expect(namespace).to eq('ac'),
                             "wrong namespace for :#{attrib.to_s}\n  expected: 'ac'\n       got: '#{namespace}"
      end
    end

    it "has namespacesed attributes for all models" do
      HydraEditor.models.each do |model_str|
        model = model_str.constantize
        attribute_definitions = model.defined_attributes.select do |name, definition|
          definition.dsid != "RELS-EXT"
        end
        attribute_definitions.each do |attrib_str, attrib_info|
          attrib = attrib_str.to_sym
          dsid = attrib_info.dsid
          namespace = model.new.datastreams[dsid].class.terminology.terms[attrib].namespace_prefix
          expect(namespace).to_not be_blank,
                                   "wrong namespace for #{model_str}.#{attrib.to_s}\n  expected: 'ac'\n       got: '#{namespace}"
        end
      end
    end
  end


  describe 'getting and setting relationships:' do
    let(:pdf) { FactoryGirl.create(:tufts_pdf) }
    let(:fake_pid) {
      pid = 'fake:123'
      ActiveFedora::Base.find(pid).destroy if ActiveFedora::Base.exists?(pid)
      pid
    }

    it 'can set a relationship to an object that exists' do
      new_value = [ { "relationship_name" => "has_annotation",
                      "relationship_value" => pdf.pid } ]
      subject.relationship_attributes = new_value
      pids = subject.ids_for_outbound(:has_annotation)
      expect(pids).to eq [pdf.pid]
    end

    it 'can set a relationship to an object that does not exist' do
      new_value = [ { "relationship_name" => "has_annotation",
                      "relationship_value" => fake_pid } ]
      subject.relationship_attributes = new_value

      pids = subject.ids_for_outbound(:has_annotation)
      expect(pids).to eq [fake_pid]
    end

    it 'gracefully ignores empty values' do
      missing_name = [ { "relationship_name" => "",
                         "relationship_value" => fake_pid } ]
      expect {
        subject.relationship_attributes = missing_name
      }.to_not raise_exception
    end

    it 'returns an empty array when there are no (editable) relationships' do
      expect(subject.relationship_attributes).to eq []
    end

    context 'with relationships in rels-ext' do
      let(:existing_uri)     { "info:fedora/#{pdf.pid}" }
      let(:non_existing_uri) { "info:fedora/#{fake_pid}" }

      before do
        subject.title = 'title'
        subject.displays = ['dl']
        subject.add_relationship(:has_annotation, existing_uri)
        subject.add_relationship(:has_subset, non_existing_uri)
        subject.save!
      end

      it 'deletes old values and adds new values' do
        pids = subject.ids_for_outbound(:has_annotation)
        expect(pids).to eq [pdf.pid]

        pid_123 = 'newpid:123'
        new_values = [{ "relationship_name" => "has_annotation",
                        "relationship_value" => pid_123 }]
        subject.relationship_attributes = new_values

        pids = subject.ids_for_outbound(:has_annotation)
        expect(pids).to eq [pid_123]
      end

      it 'returns an array of relationship builders for the edit form' do
        # A second annotation
        another_pid = 'pid:876'
        another_uri = "info:fedora/#{another_pid}"
        subject.add_relationship(:has_annotation, another_uri)

        builders = subject.relationship_attributes
        expect(builders.length).to eq 3

        annotation_1 = builders.select{ |b| b.relationship_name == :has_annotation && b.relationship_value == another_pid }
        annotation_2 = builders.select{ |b| b.relationship_name == :has_annotation && b.relationship_value == pdf.pid }
        subset = builders.select{ |b| b.relationship_name == :has_subset && b.relationship_value == fake_pid }

        expect(annotation_1.length).to eq 1
        expect(annotation_2.length).to eq 1
        expect(subset.length).to eq 1
      end

      it "user shouldn't be able to edit has_model" do
        expect(subject.rels_ext_edit_fields.include?(:has_model)).to be false

        new_values = [{ "relationship_name" => "has_model",
                        "relationship_value" => fake_pid }]
        subject.relationship_attributes = new_values

        predicate = subject.object_relations.uri_predicate(:has_model)
        new_model = subject.object_relations.relationships[predicate]
        expect(new_model).to eq ["info:fedora/afmodel:TuftsBase"]
      end
    end  # 'with relationships in rels-ext'

    describe 'validating relationships:' do
      let(:bad_pid) { 'pid with spaces' }
      let(:new_rels) {[ { "relationship_name" => :has_annotation,
                          "relationship_value" => bad_pid } ]}
      let(:attrs) { { title: 'Title', displays: ['dl'],
                      relationship_attributes: new_rels } }
      let(:record) { TuftsBase.new(attrs) }

      it 'has errors for invalid relationships' do
        expect(record).to_not be_valid
        expect(record.errors[:base].first).to eq "Invalid relationship: \"Has Annotation\" : \"#{bad_pid}\""
      end

      it 'keeps track of invalid relationships so they can be displayed on edit form' do
        rel = record.relationship_attributes.first
        expect(rel.relationship_name).to eq :has_annotation
        expect(rel.relationship_value).to eq bad_pid
        expect(record.relationship_attributes.length).to eq 1
      end
    end
  end  # 'getting and setting relationships'


  describe 'OAI ID' do

    it "assigns an OAI ID to an object with a 'dl' display" do
      obj = TuftsBase.new(title: 'foo', displays: ['dl'])
      obj.save!
      expect(oai_id(obj)).to eq "oai:#{obj.pid}"
    end

    it "does not assign OAI ID to an object with a non-'dl' display" do
      obj = TuftsBase.new(title: 'foo', displays: ['tisch'])
      obj.save!
      rels_ext = Nokogiri::XML(obj.rels_ext.content)
      namespace = "http://www.openarchives.org/OAI/2.0/"
      expect(prefix = rels_ext.namespaces.key(namespace)).to be_nil
    end

    it 'does not change an existing OAI ID when you save the object' do
      existing_oai_id = 'oai:old_id'
      obj = TuftsBase.new(title: 'foo', displays: ['dl'])
      obj.object_relations.add(:oai_item_id, existing_oai_id, true)
      obj.save!
      expect(oai_id(obj)).to eq existing_oai_id
    end

    it "does not remove the OAI ID if a 'dl' object is changed to a non-'dl' object" do
      obj = TuftsBase.new(title: 'foo', displays: ['dl'])
      obj.save!

      obj.displays = ['tisch']
      obj.save!
      expect(oai_id(obj)).to eq "oai:#{obj.pid}"
    end

    it "generates an OAI ID if an existing object is changed to display portal 'dl'" do
      obj = TuftsBase.new(title: 'foo', displays: ['tisch'])
      obj.save!

      obj.displays = ['dl']
      obj.save!
      expect(oai_id(obj)).to eq "oai:#{obj.pid}"
    end
  end

  def oai_id(obj)
    rels_ext = Nokogiri::XML(obj.rels_ext.content)
    namespace = "http://www.openarchives.org/OAI/2.0/"
    prefix = rels_ext.namespaces.key(namespace).match(/xmlns:(.*)/)[1]
    rels_ext.xpath("//rdf:Description/#{prefix}:itemID").text
  end


  describe '.stored_collection_id' do
    describe 'with an existing collection' do
      it "reads the collection_id" do
        m = TuftsBase.new(collection: TuftsEAD.new(pid: 'orig'))
        expect(m.stored_collection_id).to eq 'orig'
      end
    end
    describe 'with an existing ead' do
      it "reads the ead_id" do
        m = TuftsBase.new(ead: TuftsEAD.new(pid: 'orig'))
        expect(m.stored_collection_id).to eq 'orig'
      end
    end
    describe "with a specified collection that doesn't exist yet" do
      it "reads the collection_id" do
        m = TuftsBase.new
        m.add_relationship(m.object_relations.uri_predicate(:is_member_of), 'info:fedora/orig')
        expect(m.stored_collection_id).to eq 'orig'
      end
    end
    describe "with a specified ead that doesn't exist yet" do
      it "reads the ead_id" do
        m = TuftsBase.new
        m.add_relationship(m.object_relations.uri_predicate(:has_description), 'info:fedora/orig')
        expect(m.stored_collection_id).to eq 'orig'
      end
    end
  end

  describe '.stored_collection_id=' do
    subject do
      c = TuftsEAD.create(title: 'collection', displays: ['dl'])
      m = TuftsBase.new(title: 't', collection: c, displays: ['dl'])
      m.save! # savign to make it write rels_ext.content
      expect(m.rels_ext.to_rels_ext).to match(/isMemberOf.+resource='info:fedora\/#{c.pid}'/)
      m
    end

    it "updates the rels_ext.content" do
      c = subject.collection
      subject.stored_collection_id = 'changed'
      subject.save! # saving to make sure no other hooks overwrite the rels_ext.content
      expect(subject.rels_ext.content).to match(/hasDescription.+resource="info:fedora\/changed"/)
      expect(subject.rels_ext.content).to match(/isMemberOf.+resource="info:fedora\/changed"/)
      expect(subject.rels_ext.content).to_not match(/isMemberOf.+resource="info:fedora\/#{c.pid}"/)
    end

    it "deletes a relationship" do
      c = subject.collection
      subject.stored_collection_id = nil
      subject.save! # saving to make sure no other hooks overwrite the rels_ext.content
      expect(subject.rels_ext.content).to_not match(/isMemberOf.+resource="info:fedora\/#{c.pid}"/)
    end

    it "doesn't remove existing relationships" do
      subject.relationship_attributes = [
        {"relationship_name"=>"has_equivalent", "relationship_value"=>"same"}
      ]
      subject.stored_collection_id = 'collection'
      rel = subject.relationship_attributes.find{|r| r.relationship_name == :has_equivalent}
      expect(rel.relationship_value).to eq "same"
    end

    it "lets you create a category after creating the relationship" do
      pid = 'tufts:deferred'

      # make sure this doesn't exist because we don't truncate our db before running the tests
      TuftsEAD.find(pid).destroy if TuftsEAD.exists?(pid)

      m = TuftsBase.new(title: 't', displays: ['dl'])
      m.stored_collection_id = pid
      m.save!
      expect(m.collection).to be_nil
      c = TuftsEAD.create(title: 'collection', pid: pid, displays: ['dl'])
      m.reload
      expect(m.collection).to eq c
    end
  end

  describe 'Batch operations' do
    it 'has a field for batch_id' do
      subject.batch_id = ['1', '2', '3']
      expect(subject.batch_id).to eq ['1', '2', '3']
    end
  end

  describe '#publish!' do
    let(:user) { FactoryGirl.create(:user) }

    before do
      @obj = TuftsBase.new(title: 'My title', displays: ['dl'])
      @obj.save!

      prod = Rubydora.connect(ActiveFedora.data_production_credentials)
      expect(prod).to receive(:purge_object).with(pid: @obj.pid)
      expect(prod).to receive(:ingest)
      allow(@obj).to receive(:production_fedora_connection).and_return(prod)
    end

    after do
      @obj.delete if @obj
    end

    it 'adds an entry to the audit log' do
      @obj.publish!(user.id)
      @obj.reload
      expect(@obj.audit_log.who.include?(user.user_key)).to be true
      expect(@obj.audit_log.what).to eq ['Pushed to production']
    end

    it 'publishes the record to the production fedora' do
      @obj.publish!
      @obj.reload
      expect(@obj.published?).to be true
    end

    it 'only updates the published_at time when actually published' do
      expect(@obj.published_at).to eq nil
      expect(@obj.admin).to receive(:published_at=).once
      @obj.publish!(user.id)
      @obj.save!
    end
  end

  describe '.revert_to_production' do
    let(:user) { FactoryGirl.create(:user) }
    after do
      @model.delete if @model
    end

    context "record exists on prod and staging (normal case)" do
      before do
        @model = FactoryGirl.create(:tufts_pdf, title: "prod title")
        @model.publish!(user.id)
        @model.title = "staging title"
        @model.save!
      end

      it 'replaces the record with the one in production' do
        TuftsBase.revert_to_production(@model.pid)
        expect(@model.reload.title).to eq "prod title"
      end

      it 'saves the object as published' do
        published_at = @model.published_at
        # setting this both places to make sure both get updated
        @model.published_at = 2.days.ago
        @model.admin.published_at = 2.days.ago
        @model.save!

        TuftsBase.revert_to_production(@model.pid)

        @model.reload
        expect(@model.published?).to be true
        expect(@model.published_at).to eq published_at
        expect(@model.admin.published_at.first).to eq published_at
      end

      it "uses the 'archive' context so we can save the pid correctly" do
        @model.save!
        api = double
        allow(Rubydora).to receive(:connect) { double(api: api) }
        allow(TuftsBase).to receive(:connection_for_pid) { double(purge_object: true, ingest: true) }
        expect(api).to receive(:export) do |data|
          expect(data[:context]).to eq 'archive'
        end
        TuftsBase.revert_to_production(@model.pid)
      end
    end

    context "record exists on prod, but not on staging" do
      before do
        model = FactoryGirl.create(:tufts_pdf, title: "prod title")
        model.publish!(user.id)
        @pid = model.pid
        model.delete
        TuftsBase.revert_to_production(@pid)
      end
      it 'copys the record from production' do
        expect(TuftsPdf.exists?(@pid)).to be true
        expect(TuftsPdf.find(@pid).title).to eq "prod title"
      end
    end

    context "record doesn't exist on prod, exists on staging" do
      before do
        @model = FactoryGirl.create(:tufts_pdf, title: "prod title")
        @model.purge!
      end
      it 'raises an error' do
        expect{TuftsBase.revert_to_production(@model.pid)}.to raise_error(ActiveFedora::ObjectNotFoundError)
      end
    end
  end

  describe "#purge!" do
    subject { TuftsBase.create(title: 'some title') }
    before do
      TuftsPdf.connection_for_pid('tufts:1')
      @prod = Rubydora.connect(ActiveFedora.data_production_credentials)
      allow(subject).to receive(:production_fedora_connection) { @prod }
    end
    it "hard deletes this pid on production" do
      expect(@prod).to receive(:purge_object).with(pid: subject.pid)
      subject.purge!
    end

    it "soft deletes this pid on staging" do
      subject.purge!
      expect(subject.state).to eq "D"
    end
  end

  describe 'audit log' do
    let(:user) { FactoryGirl.create(:user) }
    before do
      subject.title = 'Some Title'
      subject.displays = ['dl']
      subject.working_user = user
    end
    after { subject.delete if subject.persisted? }

    it 'adds an entry if the content changes' do
      allow(subject).to receive(:content_will_update).and_return('hello content')
      subject.save!
      expect(subject.audit_log.who.include?(user.user_key)).to be true
      expect(subject.audit_log.what.include?('Content updated: hello content')).to be true
    end

    it 'adds an entry if the metadata changes' do
      allow(subject.admin).to receive(:changed?).and_return(true)
      subject.save!
      expect(subject.audit_log.who.include?(user.user_key)).to be true
      messages = subject.audit_log.what.select {|x| x.match(/Metadata updated/)}
      expect(messages.any?{|msg| msg.match(/DCA-ADMIN/)}).to be true
    end
  end

end
