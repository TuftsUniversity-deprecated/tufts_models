require 'spec_helper'

describe TuftsBase do

  it 'knows which fields to display for admin metadata' do
    subject.admin_display_fields.should == [:steward, :name, :comment, :retentionPeriod, :displays, :embargo, :status, :startDate, :expDate, :qrStatus, :rejectionReason, :note, :createdby, :creatordept]
  end

  it 'batch_id is not editable by users' do
    subject.terms_for_editing.include?(:batch_id).should be_false
  end

  describe 'required fields:' do
    it 'requires a title' do
      subject.required?(:title).should be_true
    end

    it 'requires displays' do
      subject.required?(:displays).should be_true
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
        expect(subject.rels_ext_edit_fields.include?(:has_model)).to be_false

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
        expect(record.valid?).to be_false
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
      oai_id(obj).should == "oai:#{obj.pid}"
    end

    it "does not assign OAI ID to an object with a non-'dl' display" do
      obj = TuftsBase.new(title: 'foo', displays: ['tisch'])
      obj.save!
      rels_ext = Nokogiri::XML(obj.rels_ext.content)
      namespace = "http://www.openarchives.org/OAI/2.0/"
      prefix = rels_ext.namespaces.key(namespace).should be_nil
    end

    it 'does not change an existing OAI ID when you save the object' do
      existing_oai_id = 'oai:old_id'
      obj = TuftsBase.new(title: 'foo', displays: ['dl'])
      obj.object_relations.add(:oai_item_id, existing_oai_id, true)
      obj.save!
      oai_id(obj).should == existing_oai_id
    end

    it "does not remove the OAI ID if a 'dl' object is changed to a non-'dl' object" do
      obj = TuftsBase.new(title: 'foo', displays: ['dl'])
      obj.save!

      obj.displays = ['tisch']
      obj.save!
      oai_id(obj).should == "oai:#{obj.pid}"
    end

    it "generates an OAI ID if an existing object is changed to display portal 'dl'" do
      obj = TuftsBase.new(title: 'foo', displays: ['tisch'])
      obj.save!

      obj.displays = ['dl']
      obj.save!
      oai_id(obj).should == "oai:#{obj.pid}"
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
      expect(m.rels_ext.to_rels_ext).to match(/isMemberOf.+resource="info:fedora\/#{c.pid}"/)
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
      subject.batch_id.should == ['1', '2', '3']
    end
  end

  describe '#publish!' do
    let(:user) { FactoryGirl.create(:user) }

    before do
      @obj = TuftsBase.new(title: 'My title', displays: ['dl'])
      @obj.save!

      prod = Rubydora.connect(ActiveFedora.data_production_credentials)
      prod.should_receive(:purge_object).with(pid: @obj.pid)
      prod.should_receive(:ingest)
      @obj.stub(:production_fedora_connection) { prod }
    end

    after do
      @obj.delete if @obj
    end

    it 'adds an entry to the audit log' do
      @obj.publish!(user.id)
      @obj.reload
      @obj.audit_log.who.include?(user.user_key).should be_true
      @obj.audit_log.what.should == ['Pushed to production']
    end

    it 'publishes the record to the production fedora' do
      @obj.publish!
      @obj.reload
      @obj.published?.should be_true
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
        expect(@model.published?).to be_true
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
        expect(TuftsPdf.exists?(@pid)).to be_true
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
      subject.stub(:content_will_update) { 'hello content' }
      subject.save!
      subject.audit_log.who.include?(user.user_key).should be_true
      subject.audit_log.what.include?('Content updated: hello content').should be_true
    end

    it 'adds an entry if the metadata changes' do
      subject.admin.stub(:changed?) { true }
      subject.save!
      subject.audit_log.who.include?(user.user_key).should be_true
      messages = subject.audit_log.what.select {|x| x.match(/Metadata updated/)}
      messages.any?{|msg| msg.match(/DCA-ADMIN/)}.should be_true
    end
  end

end
