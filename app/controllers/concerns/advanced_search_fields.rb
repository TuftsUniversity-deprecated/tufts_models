module AdvancedSearchFields
  extend ActiveSupport::Concern

  included do

    configure_blacklight do |config|

      # Attributes to include in the advanced search form
      adv_search_attrs = TuftsBase.new.terms_for_editing
      already_included_attrs = [:title, :creator, :subject, :batch]
      adv_search_attrs = adv_search_attrs - already_included_attrs

      # TODO:  I removed the format field from the search form
      # because it causes the controller to raise an exception.
      # We'll need to handle the format attribute separately.
      adv_search_attrs = adv_search_attrs - [:format]

      adv_search_attrs.each do |attr|
        field_name = attr.to_s.underscore
        config.add_search_field(field_name) do |field|
          field.include_in_simple_select = false
          field.solr_local_parameters = { :qf => field_name + '_tesim' }
        end
      end
    end

  end

end
