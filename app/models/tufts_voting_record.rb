class TuftsVotingRecord < TuftsBase

  has_file_datastream 'RECORD-XML', control_group: 'E', original: true

  def self.to_class_uri
    'info:fedora/cm:VotingRecord'
  end

end
