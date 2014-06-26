module BlacklightConfigurationHelper
  include Blacklight::ConfigurationHelperBehavior

  def document_show_fields document=nil
    if document.image?
      # archival and/or curated collection name (if possible) (optional)
      # for admin users: show what personal collections this image is a part of (optional)
      blacklight_config.show_fields.select { |k, _| ['creator_tesim', 'date_created_tesim', 'description_tesim'].include? k}
    else
      super
    end
  end
end
