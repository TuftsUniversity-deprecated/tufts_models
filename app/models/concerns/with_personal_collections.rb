module WithPersonalCollections
  extend ActiveSupport::Concern

  # Find the users own PersonalCollection which is the root collection of all their other collections.
  # @param [Boolean] create (false) When true, the personal collection will be created if it doesn't already exist
  def personal_collection(create = false)
    if create
      personal_collection || create_personal_collection!
    else
      PersonalCollection.where(id: root_pid).first
    end
  end

  def root_pid
    # escape invalid chars in pids
    # https://wiki.duraspace.org/display/FEDORA37/Fedora+Identifiers#FedoraIdentifiers-PIDspids
    escaped_user_key = user_key.gsub(/[^([A-Za-z0-9])|\-|\.|~]/){|c| '_' + c.ord.to_s(16)}
    "tufts.uc:personal_#{escaped_user_key}"
  end

  private

    def collection_title
      "Collections for #{self}"
    end

    def create_personal_collection!
      PersonalCollection.new(pid: root_pid, title: collection_title,
                            displays: [CollectionInfo.displays_in], creator: [self.user_key]).tap do |coll|
        coll.apply_depositor_metadata(self)
        coll.save!
      end
    end



end
