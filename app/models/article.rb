class Article < ActiveFedora::Base
  has_metadata "rightsMetadata", type: Hydra::Datastream::RightsMetadata
  # to use Hydra methods to manage rightsMetadata:
  include Hydra::ModelMixins::RightsMetadata
end
