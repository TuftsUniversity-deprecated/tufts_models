class TuftsRCR < TuftsBase
  has_file_datastream 'RCR-CONTENT', control_group: 'E', versionable: false, default: true

  def self.to_class_uri
    'info:fedora/cm:Text.RCR'
  end

  def file_path(name, extension=nil)
    File.join(directory_for(name), "#{PidUtils.stripped_pid(pid)}.xml")
  end

  def directory_for(name)
    File.join('RCR', 'rcr-content')
  end
end
