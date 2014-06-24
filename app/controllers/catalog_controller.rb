# -*- encoding : utf-8 -*-
class CatalogController < ApplicationController  

  include Blacklight::Catalog
  include Hydra::Controller::ControllerBehavior

  # Apply the hydra access controls
  before_filter :enforce_show_permissions, :only => :show

  # This applies appropriate access controls to all solr queries
  #CatalogController.solr_search_params_logic += [:add_access_controls_to_solr_params]

  # This filters out objects that you want to exclude from search results, like FileAssets
  CatalogController.solr_search_params_logic += [:exclude_unwanted_models]

  def index
    redirect_to contributions_path unless current_user.admin?
    @curated_collection_to_create = CuratedCollection.new
    @curated_collections = CuratedCollection.all
    super
  end


  configure_blacklight do |config|
    config.default_solr_params = { 
      :qt => 'search',
      :qf => 'id creator_tesim title_tesim subject_tesim description_tesim identifier_tesim alternative_tesim contributor_tesim abstract_tesim toc_tesim publisher_tesim source_tesim date_tesim date_created_tesim date_copyrighted_tesim date_submitted_tesim date_accepted_tesim date_issued_tesim date_available_tesim date_modified_tesim language_tesim type_tesim format_tesim extent_tesim medium_tesim persname_tesim corpname_tesim geogname_tesim genre_tesim provenance_tesim rights_tesim access_rights_tesim rights_holder_tesim license_tesim replaces_tesim isReplacedBy_tesim hasFormat_tesim isFormatOf_tesim hasPart_tesim isPartOf_tesim accrualPolicy_tesim audience_tesim references_tesim spatial_tesim bibliographic_citation_tesim temporal_tesim funder_tesim resolution_tesim bitdepth_tesim colorspace_tesim filesize_tesim steward_tesim name_tesim comment_tesim retentionPeriod_tesim displays_ssi embargo_tesim status_tesim startDate_tesim expDate_tesim qrStatus_tesim rejectionReason_tesim note_tesim',
      :rows => 10 
    }

    # solr field configuration for search results/index views
    config.index.title_field = 'title_tesim'
    config.index.display_type_field = 'has_model_ssim'

    # the method for generating thumbnails
    config.index.thumbnail_method = :make_thumbnail

    # solr field configuration for document/show views
    config.show.title_field = 'title_tesim'
    config.show.display_type_field = 'has_model_ssim'

    # solr fields that will be treated as facets by the blacklight application
    #   The ordering of the field names is the order of the display
    #
    # Setting a limit will trigger Blacklight's 'more' facet values link.
    # * If left unset, then all facet values returned by solr will be displayed.
    # * If set to an integer, then "f.somefield.facet.limit" will be added to
    # solr request, with actual solr request being +1 your configured limit --
    # you configure the number of items you actually want _tsimed_ in a page.    
    # * If set to 'true', then no additional parameters will be sent to solr,
    # but any 'sniffed' request limit parameters will be used for paging, with
    # paging at requested limit -1. Can sniff from facet.limit or 
    # f.specific_field.facet.limit solr request params. This 'true' config
    # can be used if you set limits in :default_solr_params, or as defaults
    # on the solr side in the request handler itself. Request handler defaults
    # sniffing requires solr requests to be made with "echoParams=all", for
    # app code to actually have it echo'd back to see it.  
    #
    # :show may be set to false if you don't want the facet to be drawn in the 
    # facet bar
    config.add_facet_field solr_name('names', :facetable), :label => 'Names', :limit => 7 
    config.add_facet_field solr_name('year', :facetable), :label => 'Year', :limit => 7 
    config.add_facet_field solr_name('subject', :facetable), :label => 'Subject', :limit => 7 
    config.add_facet_field solr_name('object_type', :facetable), :label => 'Format', :limit => 7
    config.add_facet_field solr_name('deposit_method', :stored_sortable), :label => 'Deposit Method', :limit => 7
    config.add_facet_field solr_name('qrStatus', :facetable), :label => 'QR Status', :limit => 7

    # Have BL send all facet field names to Solr, which has been the default
    # previously. Simply remove these lines if you'd rather use Solr request
    # handler defaults, or have no facets.
    config.default_solr_params[:'facet.field'] = config.facet_fields.keys
    #use this instead if you don't want to query facets marked :show=>false
    #config.default_solr_params[:'facet.field'] = config.facet_fields.select{ |k, v| v[:show] != false}.keys


    # solr fields to be displayed in the index (search results) view
    #   The ordering of the field names is the order of the display 
    config.add_index_field 'id', :label => 'Pid:'
    config.add_index_field solr_name('description', :stored_searchable), :label => 'Description:'
    config.add_index_field solr_name('identifier', :stored_searchable), :label => 'Identifier:'
    config.add_index_field solr_name('dateCreated', :stored_searchable), :label => 'Date Created:'
    config.add_index_field solr_name('dateAvailable', :stored_searchable), :label => 'Date Available:'

    # solr fields to be displayed in the show (single result) view
    #   The ordering of the field names is the order of the display 
    config.add_show_field 'id', :label => 'Pid:'
    config.add_show_field solr_name("object_state", :stored_sortable), :label => 'Fedora Object State', :helper_method => :fedora_object_state
    config.add_show_field solr_name('creator', :stored_searchable), :label => 'Creator:'
    config.add_show_field solr_name('source2', :stored_searchable), :label => 'Source:'
    config.add_show_field solr_name('description', :stored_searchable), :label => 'Description:'
    config.add_show_field solr_name('identifier', :stored_searchable), :label => 'Identifier:'
    config.add_show_field solr_name('dateCreated', :stored_searchable), :label => 'Date Created:'
    config.add_show_field solr_name('dateAvailable', :stored_searchable), :label => 'Date Available:'
    config.add_show_field solr_name('dateIssued', :stored_searchable), :label => 'Date Issued:'
    config.add_show_field solr_name('rights', :stored_searchable), :label => 'Rights:'
    config.add_show_field solr_name('bilbiographicCitation', :stored_searchable), :label => 'Bibliographic Citation:'
    config.add_show_field solr_name('publisher', :stored_searchable), :label => 'Publisher:'
    config.add_show_field solr_name('type2', :stored_searchable), :label => 'Type:'
    config.add_show_field solr_name('format2', :stored_searchable), :label => 'Format:'
    config.add_show_field solr_name('extent', :stored_searchable), :label => 'Extent:'
    config.add_show_field solr_name('persname', :stored_searchable), :label => 'Person:'
    config.add_show_field solr_name('corpname', :stored_searchable), :label => 'Corporation:'
    config.add_show_field solr_name('geogname', :stored_searchable), :label => 'Place:'
    config.add_show_field solr_name('genre', :stored_searchable), :label => 'Genre:'
    config.add_show_field solr_name('funder', :stored_searchable), :label => 'Subject:'
    config.add_show_field solr_name('temporal', :stored_searchable), :label => 'Temporal:'
    config.add_show_field solr_name('resolution', :stored_searchable), :label => 'Resolution:'
    config.add_show_field solr_name('bitDepth', :stored_searchable), :label => 'Bit Depth:'
    config.add_show_field solr_name('colorSpace', :stored_searchable), :label => 'Color Space:'
    config.add_show_field solr_name('filesize', :stored_searchable), :label => 'File Size:'
    config.add_show_field 'has_model_ssim', :label=>'Content Model'
    config.add_show_field 'active_fedora_model_ssi', :label=>'Hydra Class'


    # "fielded" search configuration. Used by pulldown among other places.
    # For supported keys in hash, see rdoc for Blacklight::SearchFields
    #
    # Search fields will inherit the :qt solr request handler from
    # config[:default_solr_parameters], OR can specify a different one
    # with a :qt key/value. Below examples inherit, except for subject
    # that specifies the same :qt as default for our own internal
    # testing purposes.
    #
    # The :key is what will be used to identify this BL search field internally,
    # as well as in URLs -- so changing it after deployment may break bookmarked
    # urls.  A display label will be automatically calculated from the :key,
    # or can be specified manually to be different. 

    # This one uses all the defaults set by the solr request handler. Which
    # solr request handler? The one set in config[:default_solr_parameters][:qt],
    # since we aren't specifying it otherwise. 
    
    config.add_search_field 'all_fields', :label => 'All Fields'
    

    # Now we see how to over-ride Solr request handler defaults, in this
    # case for a BL "search field", which is really a dismax aggregate
    # of Solr search fields. 
    
    config.add_search_field('title') do |field|
      # solr_parameters hash are sent to Solr as ordinary url query params. 

      # :solr_local_parameters will be sent using Solr LocalParams
      # syntax, as eg {! qf=$title_qf }. This is neccesary to use
      # Solr parameter de-referencing like $title_qf.
      # See: http://wiki.apache.org/solr/LocalParams
      field.solr_local_parameters = { 
        :qf => 'title_tesim',
        :pf => 'title_tesim'
      }
    end
    
    config.add_search_field('creator') do |field|
      field.solr_local_parameters = { 
        :qf => 'creator_tesim contributor_tesim',
        :pf => 'creator_tesim contributor_tesim'
      }
    end
    
    # Specifying a :qt only to show it's possible, and so our internal automated
    # tests can test it. In this case it's the same as 
    # config[:default_solr_parameters][:qt], so isn't actually neccesary. 
    config.add_search_field('subject') do |field|
      field.qt = 'search'
      field.solr_local_parameters = { 
        :qf => 'subject_tesim',
        :pf => 'subject_tesim'
      }
    end

    config.add_search_field('batch') do |field|
      field.solr_local_parameters = {
        :qf => 'batch_id_ssim',
        :pf => 'batch_id_ssim'
      }
    end

    include AdvancedSearchFields

    # "sort results by" select (pulldown)
    # label in pulldown is followed by the name of the SOLR field to sort by and
    # whether the sort is ascending or descending (it must be asc or desc
    # except in the relevancy case).
    config.add_sort_field 'score desc, system_create_dtsi desc, title_tesi asc', :label => 'Relevance'
    config.add_sort_field 'system_create_dtsi desc, title_tesi asc', :label => 'Date Added'
    config.add_sort_field 'creator_tesi asc, title_tesi asc', :label => 'Creator'
    config.add_sort_field 'title_tesi asc, system_create_dtsi desc', :label => 'Title'

    # If there are more than this many search results, no spelling ("did you 
    # mean") suggestion is offered.
    config.spell_max = 5

    # Add larger pagination options per Tufts request
    config.per_page = [10,20,50,100,500,1000]

    config.view[:slideshow] = false

  end

protected

  def exclude_unwanted_models(solr_parameters, user_parameters)
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << "NOT #{ActiveFedora::SolrService.solr_name("object_state", :stored_sortable)}:\"D\""
    solr_parameters[:fq] << filter_templates
  end

  def filter_templates
    "NOT active_fedora_model_ssi:TuftsTemplate"
  end
end 
