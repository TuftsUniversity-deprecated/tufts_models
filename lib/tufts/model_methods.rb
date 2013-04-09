# COPIED From https://github.com/mkorcy/tdl_hydra_head/blob/master/lib/tufts/model_methods.rb
require 'chronic'

# MISCNOTES:
# There will be no facet for RCR. There will be no way to reach RCR via browse.
# 3. There will be a facet for "collection guides", namely EAD, namely the landing page view we discussed on Friday.

module Tufts
  module ModelMethods
  include TuftsFileAssetsHelper

    def self.get_metadata(fedora_obj)
      datastream = fedora_obj.datastreams["DCA-META"]

      # create the union (ie, without duplicates) of subject, geogname, persname, and corpname
      subjects = []
      Tufts::MetadataMethods.union(subjects, datastream.find_by_terms_and_value(:subject))
      Tufts::MetadataMethods.union(subjects, datastream.find_by_terms_and_value(:geogname))
      Tufts::MetadataMethods.union(subjects, datastream.find_by_terms_and_value(:persname))
      Tufts::MetadataMethods.union(subjects, datastream.find_by_terms_and_value(:corpname))

      return {
          :titles => datastream.find_by_terms_and_value(:title),
          :creators => datastream.find_by_terms_and_value(:creator),
          :dates => datastream.find_by_terms_and_value(:dateCreated2),
          :descriptions => datastream.find_by_terms_and_value(:description),
          :sources => datastream.find_by_terms_and_value(:source2),
          :citable_urls => datastream.find_by_terms_and_value(:identifier),
          :citations => datastream.find_by_terms_and_value(:bibliographicCitation),
          :publishers => datastream.find_by_terms_and_value(:publisher),
          :genres => datastream.find_by_terms_and_value(:genre),
          :types => datastream.find_by_terms_and_value(:type2),
          :formats => datastream.find_by_terms_and_value(:format2),
          :rights => datastream.find_by_terms_and_value(:rights),
          :subjects => subjects,
          :temporals => datastream.find_by_terms_and_value(:temporal)
      }
    end

    def index_sort_fields(solr_doc)
      #CREATOR SORT
      names = self.datastreams["DCA-META"].get_values(:creator)


      unless names.empty?
        ::Solrizer::Extractor.insert_solr_field_value(solr_doc, "author_sort", "#{names[0]}")
      end

      #TITLE SORT

      titles = self.datastreams["DCA-META"].get_values(:title)


      unless titles.empty?
        ::Solrizer::Extractor.insert_solr_field_value(solr_doc, "title_sort", "#{titles[0]}")
      end

    end

    def index_fulltext(solr_doc)
      full_text = ""
      models = self.relationships(:has_model)
      if models
        models.each do |model|
          # Possible bug. Seems like full_text is overwritten if there are multiple models
          full_text = case model
          when "info:fedora/afmodel:TuftsPdf", "info:fedora/cm:Text.FacPub", "info:fedora/afmodel:TuftsFacultyPublication", "info:fedora/cm:Text.PDF"
            extract_fulltext_from_pdf()
          when "info:fedora/cm:Text.TEI", "info:fedora/afmodel.TuftsTEI","info:fedora/cm:Audio.OralHistory", "info:fedora/afmodel:TuftsAudioText","info:fedora/cm:Text.EAD", "info:fedora/afmodel:TuftsEAD"
            extract_fulltext_from_xml()
          end
        end
      end

      ::Solrizer::Extractor.insert_solr_field_value(solr_doc, "text", full_text)
    end

    def extract_fulltext_from_xml
      # some objects have inconsistent name for the datastream
      datastream = self.datastreams["Archival.xml"] || self.datastreams["ARCHIVAL_XML"]

      return unless datastream && datastream.dsLocation
      nokogiri_doc = Nokogiri::XML(File.open(convert_url_to_local_path(datastream.dsLocation)).read)
      nokogiri_doc.xpath('//text()').text.gsub(/[^0-9A-Za-z]/, ' ')
    end

    def extract_fulltext_from_pdf
      processing_url = Settings.processing_url
      repository_url = Settings.repository_url
      unless processing_url == "SKIP"
        url = processing_url + '/tika/TikaPDFExtractionServlet?doc='+ repository_url +'/fedora/objects/' + pid + '/datastreams/Archival.pdf/content&amp;chunkList=true'
        logger.info "Processing #{url}"
        begin
          nokogiri_doc = Nokogiri::XML(open(url).read)
          return nokogiri_doc.xpath('//text()').text.gsub(/[^0-9A-Za-z]/, ' ')
        rescue => e
          case e
            when OpenURI::HTTPError
              logger.error "HTTPError while indexing full text #{pid}"
            when SocketError
              logger.error "SocketError while indexing full text #{pid}"
            else
              logger.error "Error while indexing full text #{pid}"
          end
        rescue SystemCallError => e
          if e === Errno::ECONNRESET
            logger.error "Connection Reset while indexing full text #{pid}"
          else
            logger.error "SystemCallError while indexing full text #{pid}"
          end
        end
      end
      return
    end

    def create_facets(solr_doc)
      index_names_info(solr_doc)
      index_subject_info(solr_doc)
      index_collection_info(solr_doc)
      index_date_info(solr_doc)
      index_format_info(solr_doc)
      index_pub_date(solr_doc)
      index_unstemmed_values(solr_doc)
    end

  def index_unstemmed_values(solr_doc)
    #collection_id_unstem_search^5000
    #corpname_unstem_search^500
    [:corpname].each { |subject_field|
      subjects = self.datastreams["DCA-META"].get_values(subject_field)

      subjects.each { |subject|
        unless subject.downcase.include? 'unknown'
          clean_subject = Titleize.titleize(subject);
          ::Solrizer::Extractor.insert_solr_field_value(solr_doc, "corpname_unstem_search", "#{clean_subject}")
        end
      }

    } #end name_field
      #persname_unstem_search^500
      #geogname_unstem_search^500
    [:geogname].each { |subject_field|
      subjects = self.datastreams["DCA-META"].get_values(subject_field)

      subjects.each { |subject|
        unless subject.downcase.include? 'unknown'
          clean_subject = Titleize.titleize(subject);
          ::Solrizer::Extractor.insert_solr_field_value(solr_doc, "geogname_unstem_search", "#{clean_subject}")
        end
      }

    } #end name_field

    [:subject].each { |subject_field|
      subjects = self.datastreams["DCA-META"].get_values(subject_field)

      subjects.each { |subject|
        unless subject.downcase.include? 'unknown'
          clean_subject = Titleize.titleize(subject);
          ::Solrizer::Extractor.insert_solr_field_value(solr_doc, "subject_topic_unstem_search", "#{clean_subject}")
        end
      }

    } #end name_field

    #funder_unstem_search^500
    #persname_unstem_search^500
    [:persname].each { |name_field|
      names = self.datastreams["DCA-META"].get_values(name_field)

      names.each { |name|
        unless name.downcase.include? 'unknown'
          clean_name = Titleize.titleize(name)
          ::Solrizer::Extractor.insert_solr_field_value(solr_doc, "persname_unstem_search", "#{clean_name}")
        end
      }
    }
    [:creator].each { |name_field|
      names = self.datastreams["DCA-META"].get_values(name_field)

      names.each { |name|
        unless name.downcase.include? 'unknown'
          clean_name = Titleize.titleize(name)
          ::Solrizer::Extractor.insert_solr_field_value(solr_doc, "author_unstem_search", "#{clean_name}")
        end
      }
    }
    [:title].each { |name_field|
      names = self.datastreams["DCA-META"].get_values(name_field)

      names.each { |name|
        unless name.downcase.include? 'unknown'
          clean_name = Titleize.titleize(name)
          ::Solrizer::Extractor.insert_solr_field_value(solr_doc, "title_unstem_search", "#{clean_name}")
        end
      }

    } #end name_field

  end

  def index_names_info(solr_doc)

    [:creator, :persname, :corpname].each { |name_field|
      names = self.datastreams["DCA-META"].get_values(name_field)

      names.each { |name|
        unless name.downcase.include? 'unknown'
          clean_name = Titleize.titleize(name)
          ::Solrizer::Extractor.insert_solr_field_value(solr_doc, "names_facet", "#{clean_name}")
        end
      }

    } #end name_field

  end

  def index_subject_info(solr_doc)

    [:subject, :corpname, :persname, :geogname].each { |subject_field|
      subjects = self.datastreams["DCA-META"].get_values(subject_field)

      subjects.each { |subject|
        unless subject.downcase.include? 'unknown'
          clean_subject = Titleize.titleize(subject);
          ::Solrizer::Extractor.insert_solr_field_value(solr_doc, "subject_facet", "#{clean_subject}")
        end
      }

    } #end name_field

  end
    #
    # Adds metadata about the depositor to the asset
    # Most important behavior: if the asset has a rightsMetadata datastream, this method will add +depositor_id+ to its individual edit permissions.
    #
    # Exposed visibly to users as Collection name, under the heading "Collection")
    #
    # Note: this could also be exposed via the Dublin core field "source", but the RDF is superior because it
    # contains all the possible collections, and thus would reveal, say, that Dan Dennett papers are both faculty
    # publications and part of the Dan Dennett manuscript collection.

    # Possible counter argument: because displayed facets tend to be everything before the long tail, arguably
    # collections shouldn't be displaying unless sufficient other resources in the same collections are part of the
    # result set, in which case the fine tuning enabled by using the RDF instead of the Dublin core would become
    # less relevant.


    def index_collection_info(solr_doc)

      collections = self.relationships(:is_member_of_collection)
      ead = self.relationships(:has_description)
      pid = self.pid.to_s
      ead_title = nil

      if ead.first.nil?
        # there is no hasDescription
        ead_title = get_collection_from_pid(ead_title,pid)
        if ead_title.nil?
          COLLECTION_ERROR_LOG.error "Could not determine Collection for : #{self.pid}"
        else
          clean_ead_title = Titleize.titleize(ead_title);
          ::Solrizer::Extractor.insert_solr_field_value(solr_doc, "collection_facet", clean_ead_title)
        end
      else
        ead = ead.first.gsub('info:fedora/','')
        ead_obj = TuftsEAD.load_instance(ead)
        if ead_obj.nil?
         Rails.logger.debug "EAD Nil " + ead
        else
          ead_title = ead_obj.datastreams["DCA-META"].get_values(:title).first
          ead_title = Tufts::ModelUtilityMethods.clean_ead_title(ead_title)

          #4 additional collections, unfortunately defined by regular expression parsing. If one of these has hasDescription PID takes precedence
          #"Undergraduate scholarship": PID in tufts:UA005.*
          #"Graduate scholarship": PID in tufts:UA015.012.*
          #"Faculty scholarship": PID in tufts:PB.001.001* or tufts:ddennett*
          #"Boston Streets": PID in tufts:UA069.005.DO.* should be merged with the facet hasDescription UA069.001.DO.MS102

          ead_title = get_collection_from_pid(ead_title,pid)


        end
            clean_ead_title = Titleize.titleize(ead_title)
          ::Solrizer::Extractor.insert_solr_field_value(solr_doc, "collection_id_facet", ead)
          ::Solrizer::Extractor.insert_solr_field_value(solr_doc, "collection_facet", clean_ead_title)
          ::Solrizer::Extractor.insert_solr_field_value(solr_doc, "collection_title_t", clean_ead_title)
          ::Solrizer::Extractor.insert_solr_field_value(solr_doc, "collection_id_unstem_search", ead)
      end

         # unless collections.nil?
         #   collections.each {|collection|
         #   ::Solrizer::Extractor.insert_solr_field_value(solr_doc, "collection_facet", "#{collection}") }
         # end
    end


    def get_ead_title(document)
      collections = document.relationships(:is_member_of_collection)
      ead = document.relationships(:has_description)
      pid = document.pid.to_s
      ead_title = nil

      if ead.first.nil?
        # there is no hasDescription
        ead_title = get_collection_from_pid(ead_title,pid)

      else
        ead = ead.first.gsub('info:fedora/', '')
        ead_obj = TuftsEAD.load_instance(ead)
        if ead_obj.nil?
          Rails.logger.debug "EAD Nil " + ead
        else
          ead_title = ead_obj.datastreams["DCA-META"].get_values(:title).first
          ead_title = Tufts::ModelUtilityMethods.clean_ead_title(ead_title)

          #4 additional collections, unfortunately defined by regular expression parsing. If one of these has hasDescription PID takes precedence
          #"Undergraduate scholarship": PID in tufts:UA005.*
          #"Graduate scholarship": PID in tufts:UA015.012.*
          #"Faculty scholarship": PID in tufts:PB.001.001* or tufts:ddennett*
          #"Boston Streets": PID in tufts:UA069.005.DO.* should be merged with the facet hasDescription UA069.001.DO.MS102

        end
      end

      if ead_title.blank?
        return ""
      else
	ead_title = ead_title.class == Array ? ead_title.first : ead_title
        ead = ead.class == Array ? ead.first : ead
        unless ead.nil?
          result=""
          result << "<dd>This object is in collection:</dd>"
          result << "<dt>" + link_to(ead_title,"/catalog/" + ead) + "</dt>"
        end

        raw result
      end
    end

  def get_collection_from_pid(ead_title,pid)
    if pid.starts_with? "tufts:UA005"
      ead_title = "Undergraduate scholarship"
    elsif pid.starts_with? "tufts:UA015.012"
      ead_title = "Graduate scholarship"
    elsif (pid.starts_with? "tufts:PB.001.001") || (pid.starts_with? "tufts:ddennett")
      ead_title = "Faculty scholarship"
    elsif pid.starts_with? "tufts:UA069.005.DO"
      ead_title = "Boston Streets"
    end

    ead_title
  end

  def index_pub_date(solr_doc)
      dates = self.DCA_META.get_values(:dateCreated)
      
      if dates.empty?
        dates = self.DCA_META.get_values(:temporal)
      end

      if dates.empty?
        puts "THIS PID HAS NO DATE TO INDEX :::  #{pid}"
      else
        date = dates[0]
        valid_date = Time.new

        date = date.to_s

          if (!date.nil? && !date[/^c/].nil?)
            date = date.split[1..10].join(' ')
          end
         
          #end handling circa dates

          #handle 01/01/2004 style dates
          if (!date.nil? && !date[/\//].nil?)
	    date = date[date.rindex('/')+1..date.length()]
 	    #check for 2 digit year
 	    if (date.length() == 2)
	     date = "19" + date
	    end
          end
          #end handle 01/01/2004 style dates

	  #handle n.d.
	  if (!date.nil? && date[/n\.d/])
            date = "0"
          end
          #end n.d. 

          #handle YYYY-MM-DD and MM-DD-YYYY
	  if (!date.nil? && !date[/-/].nil?)
		if (date.index('-') == 4)
		  date = date[0..date.index('-')-1]
                else
		  date = date[date.rindex('-')+1..date.length()]
		end
          end
          #end YYYY-MM-DD

	  #handle ua084 collection which has dates set as 0000-00-00
 	  pid = self.pid.to_s.downcase
          if pid[/tufts\:ua084/]
	    date="1980"
          end	
          #end ua084

          #Chronic is not gonna like the 4 digit date here it may interpret as military time, and
          #this may be imperfect but lets try this.

          unless (date.nil? || date == "0")
            if date.length() == 4
              date += "-01-01"
            elsif date.length() == 9
              date = date[0..3] += "-01-01"
            elsif date.length() == 7
              date = date[0..3] += "-01-01"
            end

            unparsed_date =Chronic.parse(date)
            unless unparsed_date.nil?
              valid_date = Time.at(unparsed_date)
            end

          end
          if date == "0"
	    valid_date_string = "0"
	  else
            valid_date_string = valid_date.strftime("%Y")
 	  end

        # ::Solrizer::Extractor.insert_solr_field_value(solr_doc, "pub_date_i", "#{valid_date_string}")
        # ::Solrizer::Extractor.insert_solr_field_value(solr_doc, "pub_date_sort", "#{valid_date_string}")
        Solrizer.insert_field(solr_doc, 'pub_date', valid_date_string, :stored_sortable) 
      end

    end
    #if possible, exposed as ranges, cf. the Virgo catalog facet "publication era". Under the heading
    #"Date". Also, if possible, use Temporal if "Date.Created" is unavailable.)

    #Only display these as years (ignore the MM-DD) and ideally group them into ranges. E.g.,
    ##if we had 4 items that had the years 2001, 2004, 2006, 2010, the facet would look like 2001-2010.
    #Perhaps these could be 10-year ranges, or perhaps, if it's not too difficult, the ranges could generate
    #automatically based on the available data.

    def index_date_info(solr_doc)
      dates = self.DCA_META.get_values(:dateCreated)

      if dates.empty?
        dates = self.DCA_META.get_values(:temporal)
      end

      if dates.empty?
        puts "THIS PID HAS NO DATE TO INDEX :::  #{pid}"
      else
        dates.each do |date|

        if date.length() == 4
          date += "-01-01"
        end

          valid_date = Chronic.parse(date)
          unless valid_date.nil?
            last_digit= valid_date.year.to_s[3,1]
            decade_lower = valid_date.year.to_i - last_digit.to_i
            decade_upper = valid_date.year.to_i + (10-last_digit.to_i)
            if decade_upper >= 2020
              decade_upper ="Present"
            end
            #::Solrizer::Extractor.insert_solr_field_value(solr_doc, "year_facet", "#{decade_lower} to #{decade_upper}")
            #::Solrizer::Extractor.insert_solr_field_value(solr_doc, "year_facet", "#{valid_date.year}f")
            Solrizer.insert_field(solr_doc, 'year', "#{decade_lower} to #{decade_upper}", :facetable) 
          end
        end
      end

    end

    # The facets in this category will have labels and several types of digital objects might fit under one label.
    #For example, if you look at the text bullet here, you will see that we have the single facet "format" which
    #includes PDF, faculty publication, and TEI).

    #The labels are:


    #Text Includes PDF, faculty publication, TEI, captioned audio.

    #Images Includes 4 DS image, 3 DS image
    #Preferably, not PDF page images, not election record images.
    #Note that this will include the individual images used in image books and other TEI, but not the books themselves.
    ##Depending on how we deal with the PDFs, this might include individual page images for PDF. Problem?

    #Datasets include wildlife pathology, election records, election images (if possible), Boston streets splash pages.
    #Periodicals any PID that begins with UP.
    #Collection guides Text.EAD
    #Audio Includes audio, captioned audio, oral history.

    def index_format_info(solr_doc)
      models = self.relationships(:has_model)
      if models
        models.each do |model|
          insert_object_type(solr_doc, model)
        end 
      end
    end

    def insert_object_type(solr_doc, model)
      model_s = case model
      when "info:fedora/cm:WP","info:fedora/afmodel:TuftsWP","info:fedora/afmodel:TuftsTeiFragmented","info:fedora/cm:Text.TEI-Fragmented","info:fedora/afmodel:TuftsVotingRecord","info:fedora/cm:VotingRecord"
        "Datasets"
      when "info:fedora/cm:Text.EAD", "info:fedora/afmodel:TuftsEAD"
        "Collection Guides"
      when "info:fedora/cm:Audio", "info:fedora/afmodel:TuftsAudio","info:fedora/cm:Audio.OralHistory","info:fedora/afmodel:TuftsAudioText"
        "Audio"
      when "info:fedora/cm:Image.4DS","info:fedora/cm:Image.3DS","info:fedora/afmodel:TuftsImage","info:fedora/cm:Image.HTML"
        pid.starts_with?("tufts:MS115") ? "Datasets" : "Images"
      when "info:fedora/cm:Text.PDF","info:fedora/afmodel:TuftsPdf","info:fedora/afmodel:TuftsTEI","info:fedora/cm:Text.TEI","info:fedora/cm:Text.FacPub","info:fedora/afmodel:TuftsFacultyPublication"
        pid.starts_with?("tufts:UP") ? "Periodicals" : "Text"
      when "info:fedora/cm:Object.Generic","info:fedora/afmodel:TuftsGenericObject"
        "Generic Objects"
      else
        COLLECTION_ERROR_LOG.error "Could not determine Format for : #{pid} with model #{model.inspect}"
      end

      Solrizer.insert_field(solr_doc, 'object_type', model_s, :facetable) if model_s


      # At this point primary classification is complete but there are some outlier cases where we want to
      # Attribute two classifications to one object, now's the time to do that
      ##,"info:fedora/cm:Audio.OralHistory","info:fedora/afmodel:TuftsAudioText" -> needs text
      ##,"info:fedora/cm:Image.HTML" -->needs text
      if ["info:fedora/cm:Audio.OralHistory","info:fedora/afmodel:TuftsAudioText","info:fedora/cm:Image.HTML"].include? model
        Solrizer.insert_field(solr_doc, 'object_type', 'Text', :facetable) 
      end
    end
  end
end

