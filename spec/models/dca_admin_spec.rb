require 'spec_helper'

describe DcaAdmin do

  subject { DcaAdmin.new(nil, 'DCA-ADMIN') }

  it 'has template_name' do
    title = 'Title for a Template'
    subject.template_name = title
    expect(subject.template_name).to eq [title]
  end

  it "should have a published date" do
    time = DateTime.parse('2013-03-22T12:33:00Z')
    subject.published_at = time
    expect(subject.published_at).to eq [time]
  end

  it "should have an edited date" do
    time = DateTime.parse('2013-03-22T12:33:00Z')
    subject.edited_at = time
    expect(subject.edited_at).to eq [time]
  end

  describe "to_solr" do
    let(:doc) { DcaAdmin.new(nil, 'DCA-ADMIN') }
    let(:time) { DateTime.parse('2013-03-22T12:33:00Z') }
    before do
      doc.edited_at = time
      doc.published_at = time
      doc.embargo='2023-06-12'
      doc.displays = ['dl', 'tdil']
    end

    subject { doc.to_solr }

    it "should index the published, edited and embargo dates" do
      expect(subject['edited_at_dtsi']).to eq '2013-03-22T12:33:00Z'
      expect(subject['published_at_dtsi']).to eq '2013-03-22T12:33:00Z'
      expect(subject['embargo_dtsim']).to eq ['2023-06-12T00:00:00Z']
    end

    it "should index displays so the tufts-image-library app can search for items" do
      expect(subject['displays_ssim']).to match_array ['dl', 'tdil']
    end

  end


  it "should have note" do
    subject.note = 'self-deposit'
    expect(subject.note).to eq ['self-deposit']
    subject.note = 'admin-deposit'
    expect(subject.note).to eq ['admin-deposit']
  end

  it "should have createdby" do
    subject.createdby = 'selfdep'
    expect(subject.createdby).to eq ['selfdep']
    subject.createdby = 'admin-deposit'
    expect(subject.createdby).to eq ['admin-deposit']
  end

  it "should have creatordept" do
    subject.creatordept = 'Dept. of Biology'
    expect(subject.creatordept).to eq ['Dept. of Biology']
  end

  it 'has batch_id' do
    subject.batch_id = ['1', '2', '3']
    expect(subject.batch_id).to eq ['1', '2', '3']
  end

  context "parsing xml" do
    context "that has nodes with the default namespace" do
      let(:source) { "<admin #{namespaces}> <steward>Hey</steward> </admin>" }

      before do
        subject.content = source
      end

      context "and without a prefix 'ac' defined" do
        let(:namespaces) { 'xmlns="http://nils.lib.tufts.edu/dcaadmin/"' }

        describe "write" do
          context "a new node" do
            before do
              subject.name = ['foo']
            end

            it "should add the prefixed node" do
              expect(subject.to_xml).to eq "<admin xmlns=\"http://nils.lib.tufts.edu/dcaadmin/\" xmlns:local=\"http://nils.lib.tufts.edu/dcaadmin/\" xmlns:ac=\"http://purl.org/dc/dcmitype/\"> <steward>Hey</steward> <ac:name>foo</ac:name></admin>"
            end
          end
        end
      end

      context "and without a prefix 'local' defined" do
        let(:namespaces) { 'xmlns="http://nils.lib.tufts.edu/dcaadmin/" xmlns:ac="http://purl.org/dc/dcmitype/"' }
        describe "read" do
          it "should have steward" do
            expect(subject.steward).to eq ['Hey']
          end
        end

        describe "write" do
          context "a new node" do
            before do
              subject.note = ['foo']
            end

            it "should add the prefixed node" do
              expect(subject.to_xml).to eq "<admin xmlns=\"http://nils.lib.tufts.edu/dcaadmin/\" xmlns:ac=\"http://purl.org/dc/dcmitype/\" xmlns:local=\"http://nils.lib.tufts.edu/dcaadmin/\"> <steward>Hey</steward> <local:note>foo</local:note></admin>"
            end
          end

          context "an existing node" do
            before do
              subject.steward = ['foo', 'bar']
            end

            it "should add the prefixed node" do
              expect(subject.to_xml).to eq "<admin xmlns=\"http://nils.lib.tufts.edu/dcaadmin/\" xmlns:ac=\"http://purl.org/dc/dcmitype/\" xmlns:local=\"http://nils.lib.tufts.edu/dcaadmin/\"> <steward>foo</steward> <local:steward>bar</local:steward></admin>"
              expect(subject.steward).to eq ['foo', 'bar']
            end
          end
        end
      end

      context "source with both prefix" do
        let(:namespaces) { 'xmlns="http://nils.lib.tufts.edu/dcaadmin/" xmlns:local="http://nils.lib.tufts.edu/dcaadmin/" xmlns:ac="http://purl.org/dc/dcmitype/"' }
        it "should have steward" do
          expect(subject.steward).to eq ['Hey']
        end
      end
    end

    context "with nodes that are prefixed" do
      let(:source) { "<admin #{namespaces}> <local:steward>Hey</local:steward> </admin>" }

      before do
        subject.content = source
      end

      context "and the local prefix is defined and no default namespace" do
        let(:namespaces) { 'xmlns:local="http://nils.lib.tufts.edu/dcaadmin/" xmlns:ac="http://purl.org/dc/dcmitype/"' }
        it "should have steward" do
          expect(subject.steward).to eq ['Hey']
        end
      end

      context "and a local prefix and the default namespace are defined" do
        let(:namespaces) { 'xmlns="http://nils.lib.tufts.edu/dcaadmin/" xmlns:local="http://nils.lib.tufts.edu/dcaadmin/" xmlns:ac="http://purl.org/dc/dcmitype/"' }
        describe "read" do
          it "should have steward" do
            expect(subject.steward).to eq ['Hey']
          end
        end

        describe "write" do
          context "a new 'local' node" do
            before do
              subject.note = ['foo']
            end

            it "should add the prefixed node" do
              expect(subject.to_xml).to eq "<admin xmlns=\"http://nils.lib.tufts.edu/dcaadmin/\" xmlns:local=\"http://nils.lib.tufts.edu/dcaadmin/\" xmlns:ac=\"http://purl.org/dc/dcmitype/\"> <local:steward>Hey</local:steward> <local:note>foo</local:note></admin>"
            end
          end

          context "an existing node" do
            before do
              subject.steward = ['foo', 'bar']
            end

            it "should add the prefixed node" do
              expect(subject.to_xml).to eq "<admin xmlns=\"http://nils.lib.tufts.edu/dcaadmin/\" xmlns:local=\"http://nils.lib.tufts.edu/dcaadmin/\" xmlns:ac=\"http://purl.org/dc/dcmitype/\"> <local:steward>foo</local:steward> <local:steward>bar</local:steward></admin>"
            end
          end
        end
      end
    end
  end

end
