# For parsing the TuftsVideo TEI transcript xml

require "om"

  class TuftsTeiMeta

  include OM::XML::Document

    set_terminology do |t|
      t.root(:path => "TEI.2", :namespace_prefix => nil, :xmlns => "", :schema => "http://dca.tufts.edu/schema/tei/tei2.dtd")

      t.teiHeader(:path => "teiHeader", :namespace_prefix => nil) {
        t.fileDesc(:path => "fileDesc", :namespace_prefix => nil) {
          t.titleStmt(:path => "titleStmt", :namespace_prefix => nil) {
              t.title(:path => "title", :namespace_prefix => nil)
              t.author(:path => "author", :namespace_prefix => nil)
          }
        }
        t.profileDesc(:path => "profileDesc", :namespace_prefix => nil) {
          t.particDesc(:path => "particDesc", :namespace_prefix => nil) {
            t.person(:path => "person", :namespace_prefix => nil) {
              t.id_attr(:path => {:attribute => "id"}, :namespace_prefix => nil)
              t.role_attr(:path => {:attribute => "role"}, :namespace_prefix => nil)
              t.p(:path => "p", :namespace_prefix => nil)
            }
          }
        }
      }

      t.text(:path => "text", :namespace_prefix => nil) {
        t.body(:path => "body", :namespace_prefix => nil) {
          t.timeline(:path => "timeline", :namespace_prefix => nil) {
            t.when(:path => "when", :namespace_prefix => nil)
          }
          t.div1(:path => "div1", :namespace_prefix => nil)  {
            t.u(:path => "u", :namespace_prefix => nil) {
              t.who_attr(:path => {:attribute => "who"}, :namespace_prefix => nil)
              t.u_inner(:path => "u", :namespace_prefix => nil)
            }
          }
        }
      }

      t.title(:proxy => [:teiHeader, :fileDesc, :titleStmt, :title],:index_as=>[nil])
      t.author(:proxy => [:teiHeader, :fileDesc, :titleStmt, :author])

      t.id_attr(:proxy => [:teiHeader, :profileDesc, :particDesc, :person, :id_attr])
      t.role_attr(:proxy => [:teiHeader, :profileDesc, :particDesc, :person, :role_attr])
      t.p(:proxy => [:teiHeader, :profileDesc, :particDesc, :person, :p])
      t.participants(:proxy => [:teiHeader, :profileDesc, :particDesc])
      t.when(:proxy => [:text, :body, :timeline, :when])
      t.u(:proxy => [:text, :body, :div1, :u])
      #t.who_attr(:proxy => [:text, :body, :div1, :u, :u, :who_attr])
      #t.u_inner(:proxy => [:text, :body, :div1, :u, :u_inner])
    end


    def self.xml_template
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.tuftsTeiTranscript() {
          xml.teiHeader {
            xml.fileDesc {
              xml.titleStmt {
                xml.title
                xml.author
              }
              xml.extent
              xml.publicationStmt {
                xml.distributor {
                }
                xml.address {
                  xml.addrLine
                }
                xml.idno
                xml.availability {
                  xml.p
                }
              }
              xml.sourceDesc {
                xml.recordingStmt {
                  xml.recording {
                    xml.date
                    xml.equipment {
                      xml.p
                    }
                    xml.respStmt {
                      xml.resp
                      xml.name
                    }
                  }
                }
              }
            }
            xml.encodingDesc {
              xml.editorialDecl {
                xml.stdVals {
                  xml.p
                }
              }
              xml.classDecl {
                xml.taxonomy {
                  xml.bibl {
                    xml.title
                  }
                }
              }
            }
            xml.profileDesc {
              xml.creation {
                xml.date
              }
              xml.langUsage {
                xml.language
              }
              xml.particDesc {
                xml.person {
                  xml.p
                }
              }
            }
          }
          xml.text_ {
            xml.body {
              xml.timeline {
                xml.when
              }
              xml.div1 {
                xml.u {
                  xml.u
                }
              }
            }
          }
        }
      end

      return builder.doc
    end

    def to_solr(solr_doc = Hash.new) # :nodoc:
      return solr_doc
    end

  end
