require 'spec_helper'

describe TuftsBase do

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
      c = TuftsEAD.create(title: 'collection')
      m = TuftsBase.new(title: 't', collection: c)
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

      m = TuftsBase.new(title: 't')
      m.stored_collection_id = pid
      m.save!
      expect(m.collection).to be_nil
      c = TuftsEAD.create(title: 'collection', pid: pid)
      m.reload
      expect(m.collection).to eq c
    end
  end


  describe '#apply_attributes' do
    before do
      @obj = TuftsBase.new(title: 'old title',
                           createdby: 'old createdby',
                           description: ['old desc 1', 'old desc 2'])
      @obj.save!
    end

    it 'overwrites single-value attributes' do
      @obj.apply_attributes(createdby: 'new createdby')
      @obj.reload
      @obj.createdby.should == 'new createdby'
    end

    it 'adds entries for multi-value attributes' do
      @obj.apply_attributes(description: 'new desc')
      @obj.reload
      @obj.description.should == ['old desc 1', 'old desc 2', 'new desc']
    end

    it 'adds new attributes if they didnt exist' do
      @obj.toc.should be_empty
      @obj.apply_attributes(toc: 'new toc')
      @obj.reload
      @obj.toc.should == ['new toc']
    end

    it 'returns true if the record successfully saved' do
      result = @obj.apply_attributes(description: 'new desc')
      result.should be_true
    end

    it 'returns false if the record failed to save' do
      @obj.should_receive(:save).and_return(false)
      result = @obj.apply_attributes(description: 'new desc')
      result.should be_false
    end

    it 'adds an entry to the audit log' do
      user = FactoryGirl.create(:user)
      @obj.apply_attributes({description: 'new desc'}, user.id)
      @obj.reload
      @obj.audit_log.who.include?(user.user_key).should be_true
    end
  end

end
