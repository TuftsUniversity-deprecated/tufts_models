require 'active_fedora'
require 'active_fedora_override'
require 'hydra-core'
require 'hydra-role-management'
require 'titleize'
require 'settingslogic'
require 'hydra-editor'
require 'resque-status'
require 'rmagick'
require 'qa'

module TuftsModels
  class Engine < ::Rails::Engine
    config.eager_load_paths += %W(
      #{config.root}/app/models/forms
      #{config.root}/app/models/datastreams
      #{config.root}/lib/view_objects
      #{config.root}/lib
    )
  end
end
