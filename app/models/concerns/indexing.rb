# COPIED From https://github.com/mkorcy/tdl_hydra_head/blob/master/lib/tufts/model_methods.rb
require 'chronic'

module Indexing
  extend ActiveSupport::Concern

  def to_solr(solr_doc=Hash.new)
    super.tap do |solr_doc|
      create_facets solr_doc
      create_formatted_fields solr_doc
      index_sort_fields solr_doc
    end
  end

  private
    def index_sort_fields(solr_doc)
      #CREATOR SORT
      Solrizer.insert_field(solr_doc, 'author', creator.first, :sortable) unless creator.empty?

      #TITLE SORT
      Solrizer.insert_field(solr_doc, 'title', title, :sortable) if title
    end

    # MISCNOTES:
    # There will be no facet for RCR. There will be no way to reach RCR via browse.
    # 3. There will be a facet for "collection guides", namely EAD, namely the landing page view we discussed on Friday.
    def create_facets(solr_doc)
      index_names_info(solr_doc)
      index_subject_info(solr_doc)
      index_collection_info(solr_doc)
      index_date_info(solr_doc)
      index_format_info(solr_doc)
      index_pub_date(solr_doc)
      index_unstemmed_values(solr_doc)
      index_deposit_method(solr_doc)
    end


  def index_deposit_method(solr_doc)
    case createdby
    when 'selfdep' #Contribution::SELFDEP
      Solrizer.insert_field(solr_doc, 'deposit_method', 'self-deposit', :stored_sortable)
    end
  end

  def index_unstemmed_values(solr_doc)
    titleize_and_index_array(solr_doc, 'corpname', corpname, :unstemmed_searchable)  
    titleize_and_index_array(solr_doc, 'geogname', geogname, :unstemmed_searchable)  
    titleize_and_index_array(solr_doc, 'subject_topic', subject, :unstemmed_searchable)  
    titleize_and_index_array(solr_doc, 'persname', persname, :unstemmed_searchable)  
    titleize_and_index_array(solr_doc, 'author', creator, :unstemmed_searchable)  
    titleize_and_index_single(solr_doc, 'title', title, :unstemmed_searchable)  

  end

  def index_names_info(solr_doc)
    [:creator, :contributor, :persname, :corpname].each do |name_field|
      names = self.send(name_field)
      titleize_and_index_array(solr_doc, 'names', names, :facetable)  #names_sim
    end
  end

  def index_subject_info(solr_doc)
    [:subject, :corpname, :persname, :geogname].each do |subject_field|
      subjects = self.send(subject_field)
      titleize_and_index_array(solr_doc, 'subject', subjects, :facetable)  #subject_sim
    end
  end


  def titleize_and_index_array(solr_doc, field_prefix, values, index_type)
    values.each do |name|
      titleize_and_index_single(solr_doc, field_prefix, name, index_type)
    end
  end

  def titleize_and_index_single(solr_doc, field_prefix, name, index_type)
    if name.present? &&  !name.downcase.include?('unknown')
      begin
        clean_name = Titleize.titleize(name)
      rescue TypeError
        #titelize occasionally hits an internal nil
        clean_name = name
      end
      Solrizer.insert_field(solr_doc, field_prefix, clean_name, index_type)
    end
  end

  
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
    ead_title = nil
    if ead_id.nil?
      # there is no hasDescription
      ead_title = get_collection_from_pid(pid)
      if ead_title.nil?
        COLLECTION_ERROR_LOG.error "Could not determine Collection for : #{self.pid}"
      else
        clean_ead_title = Titleize.titleize(ead_title);
        Solrizer.insert_field(solr_doc, 'collection', clean_ead_title, :facetable) 
      end
    else
      ead_title = Tufts::ModelUtilityMethods.clean_ead_title(ead.title.first) unless ead.nil?
      ead_title = get_collection_from_pid(pid, ead_title)

      unless ead_title.nil?
        clean_ead_title = Titleize.titleize(ead_title)
        Solrizer.insert_field(solr_doc, 'collection', clean_ead_title, :facetable)
        Solrizer.insert_field(solr_doc, 'collection_title', clean_ead_title, :stored_searchable)
      end

      # TODO Facetable and unstemmed_searchable might be equivalent
      Solrizer.insert_field(solr_doc, 'collection_id', ead_id, :facetable) 
      Solrizer.insert_field(solr_doc, 'collection_id', ead_id, :unstemmed_searchable) 
    end
  end


  def get_ead_title
    ead_title = nil

    ead_title = if ead.nil?
      # there is no hasDescription
      get_collection_from_pid(pid)
    else
      Tufts::ModelUtilityMethods.clean_ead_title(ead.title.first)
      #4 additional collections, unfortunately defined by regular expression parsing. If one of these has hasDescription PID takes precedence
      #"Undergraduate scholarship": PID in tufts:UA005.*
      #"Graduate scholarship": PID in tufts:UA015.012.*
      #"Faculty scholarship": PID in tufts:PB.001.001* or tufts:ddennett*
      #"Boston Streets": PID in tufts:UA069.005.DO.* should be merged with the facet hasDescription UA069.001.DO.MS102
    end

    return "" if ead_title.blank?
    ead_title = ead_title.first if ead_title.class == Array
    if ead
      result=""
      result << "<dd>This object is in collection:</dd>"
      result << "<dt>" + link_to(ead_title,"/catalog/" + ead.id) + "</dt>"
    end

    raw result
  end

  def get_collection_from_pid(pid, default=nil)
    if pid.starts_with? "tufts:UA005"
      "Undergraduate scholarship"
    elsif pid.starts_with? "tufts:UA015.012"
      "Graduate scholarship"
    elsif (pid.starts_with? "tufts:PB.001.001") || (pid.starts_with? "tufts:ddennett")
      "Faculty scholarship"
    elsif pid.starts_with? "tufts:UA069.005.DO"
      "Boston Streets"
    else
      default
    end
  end

  def index_pub_date(solr_doc)
      dates = self.date
      
      if dates.empty?
        dates = self.temporal
      end

      unless dates.empty?
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

        Solrizer.insert_field(solr_doc, 'pub_date', valid_date_string.to_i, :stored_sortable) 
      end

    end
    #if possible, exposed as ranges, cf. the Virgo catalog facet "publication era". Under the heading
    #"Date". Also, if possible, use Temporal if "Date.Created" is unavailable.)

    #Only display these as years (ignore the MM-DD) and ideally group them into ranges. E.g.,
    ##if we had 4 items that had the years 2001, 2004, 2006, 2010, the facet would look like 2001-2010.
    #Perhaps these could be 10-year ranges, or perhaps, if it's not too difficult, the ranges could generate
    #automatically based on the available data.

    def index_date_info(solr_doc)
      dates = self.date

      if dates.empty?
        dates = self.temporal
      end

      unless dates.empty?
        dates.each do |date|

        # trim trailing whitespace
        date = date.strip

        # trim trailing period as that causes problem for chronic on many dates
        date = date.first(-1) if !date.rindex('.').nil?  && date.rindex('.') + 1 == date.length

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

    def create_formatted_fields(solr_doc)
      self.date.each do |date|
        # we're storing BCE dates as -0462 using ISO-6801 standard but we want to retrieve them for display formatted for the screen
        if date.start_with? '-'
         date = "#{date.sub(/^[0\-]*/,'')} BCE"
        end

        Solrizer.insert_field(solr_doc, 'date_formatted', "#{date}", :stored_searchable) #tesim
      end
    end

    def insert_object_type(solr_doc, model)
      model_s = case model
      when "info:fedora/afmodel:TuftsVotingRecord","info:fedora/cm:VotingRecord"
        "Datasets"
      when "info:fedora/cm:Text.EAD", "info:fedora/afmodel:TuftsEAD"
        "Collection Guides"
      when "info:fedora/cm:Audio", "info:fedora/afmodel:TuftsAudio"
        "Audio"
      when "info:fedora/cm:Image.4DS","info:fedora/cm:Image.3DS","info:fedora/afmodel:TuftsImage"
        pid.starts_with?("tufts:MS115") ? "Datasets" : "Images"
      when "info:fedora/cm:Text.PDF","info:fedora/afmodel:TuftsPdf","info:fedora/afmodel:TuftsTEI","info:fedora/cm:Text.TEI"
        pid.starts_with?("tufts:UP") ? "Periodicals" : "Text"
      when "info:fedora/cm:Object.Generic","info:fedora/afmodel:TuftsGenericObject"
        "Generic Objects"
      when "info:fedora/afmodel:TuftsVideo"
        "Video"
      when "info:fedora/afmodel:TuftsTemplate"
        "Template"
      when "info:fedora/cm:Text.RCR", "info:fedora/afmodel:TuftsRCR"
        "Collection Creators"
      else
        COLLECTION_ERROR_LOG.error "Could not determine Format for : #{pid} with model #{model.inspect}"
      end

      Solrizer.insert_field(solr_doc, 'object_type', model_s, :facetable) if model_s
      Solrizer.insert_field(solr_doc, 'object_type', model_s, :symbol) if model_s


      # At this point primary classification is complete but there are some outlier cases where we want to
      # Attribute two classifications to one object, now's the time to do that
      ##,"info:fedora/cm:Audio.OralHistory","info:fedora/afmodel:TuftsAudioText" -> needs text
      ##,"info:fedora/cm:Image.HTML" -->needs text
      if ["info:fedora/cm:Audio","info:fedora/afmodel:TuftsAudio","info:fedora/afmodel:TuftsVideo"].include? model
        unless self.datastreams['ARCHIVAL_XML'].nil? || self.datastreams['ARCHIVAL_XML'].dsLocation.nil? 
          Solrizer.insert_field(solr_doc, 'object_type', 'Text', :facetable)
          Solrizer.insert_field(solr_doc, 'object_type', 'Text', :symbol)
        end
      end
    end

end
