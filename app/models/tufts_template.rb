class TuftsTemplate < ActiveFedora::Base
  include BaseModel

  # Fields can be left blank in a template.
  def required?(key)
    false
  end

  def push_to_production!
    # Templates should never be pushed to the production
    # environment.  They are meant to be used by admin users
    # to ingest files in bulk and apply the same metadata to
    # many files.  There should be no need for them to be
    # visible to general users.
    raise UnpublishableModelError.new
  end

  def published?
    false
  end

end


class UnpublishableModelError < StandardError

  def message
    'Templates cannot be pushed to production'
  end

end
