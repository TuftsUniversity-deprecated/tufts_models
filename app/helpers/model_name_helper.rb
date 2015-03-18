module ModelNameHelper

  # map_model_name() is called from modified copy of lib/active_fedora/model.rb's classname_from_uri() and to_class_uri();
  # classname_from_uri() is called when the fedora objects are being indexed.  to_class_uri() doesn't
  # actually appear to be called from anywhere.
  # map_model_name() is also called from modified copy of app/helpers/hydra/blacklight_helper_behavior.rb's
  # document_partial_name() to fix the link to the object from the search results page.
  # map_model_name() is also called from modified copy of app/helpers/hydra/hydra_assets_helper_behavior.rb's
  # document_type() to fix the document type displayed on the search results page.
  # map_model_names() is called from app/controllers/file_assets_controller.rb.


  def self.map_model_name(model_name)
    result = model_name

    if model_name.starts_with? "info:fedora/cm:"
      mapped_model_name = case model_name
      when "info:fedora/cm:Audio"
        "info:fedora/afmodel:TuftsAudio"
      when "info:fedora/cm:Audio.OralHistory"
        "info:fedora/afmodel:TuftsAudioText"
      when "info:fedora/cm:Image.3DS", "info:fedora/cm:Image.4DS"
        "info:fedora/afmodel:TuftsImage"
      when "info:fedora/cm:Text.FacPub"
        "info:fedora/afmodel:TuftsFacultyPublication"
      when "info:fedora/cm:Text.PDF"
        "info:fedora/afmodel:TuftsPdf"
      when "info:fedora/cm:Object.Generic"
        "info:fedora/afmodel:TuftsGenericObject"
      when "info:fedora/cm:Text.EAD"
        "info:fedora/afmodel:TuftsEAD"
      when "info:fedora/cm:Text.TEI"
        "info:fedora/afmodel:TuftsTEI"
      when "info:fedora/cm:Text.RCR"
        "info:fedora/afmodel:TuftsRCR"
      when "info:fedora/cm:VotingRecord"
        "info:fedora/afmodel:TuftsVotingRecord"
      end

      if mapped_model_name 
        Rails.logger.debug("map_model_name() has mapped #{model_name} to #{mapped_model_name}")
        return mapped_model_name
      end
    end

    return result
  end


  # iterate through an array of model names and call map_model_name() for each element
  def self.map_model_names(model_names)
    model_names.map { |model_name| map_model_name(model_name) }
  end


end

