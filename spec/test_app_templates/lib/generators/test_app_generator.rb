require 'rails/generators'

class TestAppGenerator < Rails::Generators::Base
  source_root "../../spec/test_app_templates"

  def generate_blacklight
    generate 'blacklight:install', '--devise'
    generate 'hydra:head', '-f'

    devise_initalizer = 'config/initializers/devise.rb'
    text = File.read(devise_initalizer)
    new_contents = text.gsub(/:email/, ":username")
    File.open(devise_initalizer, "w") {|file| file.puts new_contents }

  end

  def run_spotlight_migrations
    rake "tufts_models_engine:install:migrations"
    rake "db:migrate"
  end

  def application_initilization
    copy_file "application.yml", "config/application.yml"
  end

  def fedora_config
    copy_file "fedora.yml", "config/fedora.yml", force: true
  end

  def displays_config
    copy_file "displays.yml", "config/authorities/displays.yml", force: true
    generate 'qa:install'
  end

  # TODO move to the install generator
  # Add behaviors to the SolrDocument model
  def inject_solr_document_behavior
    file_path = "app/models/solr_document.rb"
    if File.exists?(file_path)
      inject_into_file file_path, after: /include Blacklight::Solr::Document.*$/ do
        "\n  # Adds Tufts behaviors to the SolrDocument.\n" +
          "  include Tufts::SolrDocument\n"
      end
    else
      puts "     \e[31mFailure\e[0m  TuftsModels requires a SolrDocument object. This generators assumes that the model is defined in the file #{file_path}, which does not exist."
    end
  end

  # TODO move to the install generator
  # Add behaviors to the User model
  def inject_user_behavior
    file_path = "app/models/user.rb"
    if File.exists?(file_path)
      inject_into_file file_path, after: /include Blacklight::User.*$/ do
        "\n  # Adds Tufts behaviors to the User.\n" +
          "  include Tufts::User\n"
      end
    else
      puts "     \e[31mFailure\e[0m  TuftsModels requires a user object. This generators assumes that the model is defined in the file #{file_path}, which does not exist."
    end
   gsub_file "app/models/user.rb", /email/, "username"
   gsub_file "app/models/user.rb", /devise .*$/, "devise :ldap_authenticatable, :trackable"
   gsub_file "app/models/user.rb", /:recoverable, :rememberable, :trackable, :validatable/, ""
  end
end
