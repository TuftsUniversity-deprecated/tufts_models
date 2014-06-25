require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module Tufts
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    
    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += %W(#{config.root}/lib 
                                #{config.root}/app/models/datastreams
                                #{config.root}/app/models/forms
                                #{config.root}/lib/view_objects
                               )

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    #

    MIRA = 'MIRA'.freeze
    TIL = 'TIL'.freeze
    config.application_mode = ENV['HYDRA_APP_NAME']
    raise "The environment variable HYDRA_APP_NAME was not specified. It must be set to '#{MIRA}' or '#{TIL}'" unless config.application_mode
    raise "The environment variable HYDRA_APP_NAME was not valid. It must be set to '#{MIRA}' or '#{TIL}'" unless [MIRA, TIL].include? config.application_mode

    def self.mira?
      config.application_mode == MIRA
    end

    def self.til?
      config.application_mode == TIL
    end
  end
end

if Rails.env.development? and ENV['EXPLAIN_PARTIALS']
  module ActionView
    class PartialRenderer
      def render_with_explanation(*args)
        rendered = render_without_explanation(*args).to_s
        # debugger if @template.inspect.to_s == "nil" # how do we get a path when @template is nil?
        start_explanation = "\n<!-- START PARTIAL #{@template.inspect} -->\n"
        end_explanation = "\n<!-- END PARTIAL #{@template.inspect} -->\n"
        start_explanation.html_safe + rendered + end_explanation.html_safe
      end

      alias_method_chain :render, :explanation
    end
  end
end
