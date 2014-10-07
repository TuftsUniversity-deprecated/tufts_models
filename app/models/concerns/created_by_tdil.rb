module CreatedByTdil
  extend ActiveSupport::Concern

  included do
    after_initialize :add_created_by
  end

  protected
    def add_created_by
      self.createdby ||= 'tdil'
    end
end
