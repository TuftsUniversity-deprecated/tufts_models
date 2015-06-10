class TuftsVotingRecord < TuftsBase
  has_file_datastream 'RECORD-XML', control_group: 'E', versionable: false, default: true

  def self.to_class_uri
    'info:fedora/cm:VotingRecord'
  end

end
