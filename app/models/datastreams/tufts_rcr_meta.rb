class TuftsRcrMeta < ActiveFedora::OmDatastream

  set_terminology do |t|
    t.root(:path => "eac-cpf", "xmlns" => "urn:isbn:1-931666-33-4",
      "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
      "xmlns:xlink" => "http://www.w3.org/1999/xlink",
      "xsi:schemaLocation" => "urn:isbn:1-931666-33-4 http://eac.staatsbibliothek-berlin.de/schema/cpf.xsd")
    t.recordId(:path => "recordId")
    t.maintenanceStatus(:path => "maintenanceStatus")
    t.maintenanceAgency(:path => "maintenanceAgency")
    t.languageDeclaration(:path => "languageDeclaration")
    t.conventionDeclaration(:path => "conventionDeclaration")
    t.maintenanceHistory(:path => "maintenanceHistory")
    t.sources(:path => "sources")
    t.identity(:path => "identity") {
      t.nameEntry(:path => "nameEntry") {
        t.part(:path => "part")
      }
    }
    t.description(:path => "description") {
      t.existDates(:path => "existDates") {
        t.dateRange(:path => "dateRange") {
          t.fromDate(:path => "fromDate")
          t.toDate(:path => "toDate")
        }
      }
      t.biogHist(:path => "biogHist") {
        t.abstract(:path => "abstract")
        t.p(:path => "p")
      }
      t.structureOrGenealogy(:path => "structureOrGenealogy") {
        t.p(:path => "p")
        t.list(:path => "list") {
          t.item(:path => "item")
        }
      }
    }
    t.relations(:path => "relations") {
      t.cpfRelation(:path => "cpfRelation") {
        t.relationEntry(:path => "relationEntry")
        t.dateRange(:path => "dateRange") {
          t.fromDate(:path => "fromDate")
          t.toDate(:path => "toDate")
        }
      }
      t.resourceRelation(:path => "resourceRelation") {
        t.relationEntry(:path => "relationEntry")
      }
    }

    # Title
    t.title(:proxy => [:identity, :nameEntry, :part])
    t.fromDate(:proxy => [:description, :existDates, :dateRange, :fromDate])
    t.toDate(:proxy => [:description, :existDates, :dateRange, :toDate])

    # Body
    t.bioghist_abstract(:proxy => [:description, :biogHist, :abstract])
    t.bioghist_p(:proxy => [:description, :biogHist, :p])
    t.structure_or_genealogy_p(:proxy => [:description, :structureOrGenealogy, :p])
    t.structure_or_genealogy_item(:proxy => [:description, :structureOrGenealogy, :list, :item])

    #Relationships
    t.cpf_relations(:proxy => [:relations, :cpfRelation])

    #Collections
    t.resource_relations(:proxy => [:relations, :resourceRelation])
  end


  def self.xml_template
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.tuftsRecordCreatorRecord() {
        xml.control {
          xml.recordId
          xml.maintenanceStatus
          xml.maintenanceAgency {
            xml.agencyCode
            xml.agencyName
          }
          xml.languageDeclaration {
            xml.language
            xml.script
          }
          xml.conventionDeclaration {
            xml.abbreviation
            xml.citation
            xml.descriptiveNote
          }
          xml.maintenanceHistory {
            xml.maintenanceEvent {
              xml.eventType
              xml.eventDateTime
              xml.agentType
              xml.agent
            }
          }
          xml.sources {
            xml.source {
              xml.sourceEntry
            }
          }
        }
        xml.cpfDescription {
          xml.identity {
            xml.entityType
            xml.nameEntry {
              xml.part
              xml.authorizedForm
            }
          }
          xml.description {
            xml.existDates {
              xml.dateRange {
                xml.fromDate
                xml.toDate
              }
            }
            xml.biogHist {
              xml.abstract
              xml.p
            }
            xml.structureOrGenealogy
          }
        }

        xml.relations {
          xml.cpfRelation {
            xml.relationEntry
            xml.dateRange {
              xml.fromDate
              xml.toDate
            }
          }
          xml.resourceRelation {
            xml.relationEntry
            xml.objectXMLWrap {
              xml.ead {
                xml.archdesc {
                  xml.did {
                    xml.unittitle
                    xml.unitid
                  }
                }
              }
            }
          }
        }
      }
    end

    return builder.doc
  end

end
