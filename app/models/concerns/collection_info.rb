module CollectionInfo
  extend ActiveSupport::Concern

  protected
    def self.displays_in
      'trove'
    end
end
