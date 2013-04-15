class RecordsController < ApplicationController
  include RecordsControllerBehavior

  protected
  
  # Overridden to have the models we want
  # With AF 6.1 we could probably just do:
  # ActiveFedora::Base.decendants
  def valid_types
    ["TuftsAudio", "TuftsPdf"]
  end
end
