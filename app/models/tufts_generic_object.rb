class TuftsGenericObject < TuftsBase
  has_metadata :name => "GENERIC-CONTENT", :type => TuftsGenericMeta
  #has_file_datastream 'Archival.pdf', control_group: 'E', original: true
  #
  delegate :item, :to => 'GENERIC-CONTENT'

  def self.to_class_uri
    'info:fedora/cm:Object.Generic'
  end


  # Given a datastream name, return the local path where the file can be found.
  # If an extension is provided, generate the path, if the extension is not provided,
  # derive it from the stored dsLocation
  # @example
  #   obj.file_path('GENERIC-CONTENT', 'zip')
  #   # => /local_object_store/data01/tufts/central/dca/MS054/archival_tif/MS054.003.DO.02108.archival.tif
  def file_path(name, extension=nil)
    File.join(directory_for(name), "#{pid_without_namespace}.#{extension}")
  end

  # Given a datastream name, return the directory path where the file can be found.
  # @example
  #   obj.file_path('GENERIC-CONTENT')
  #   # => /local_object_store/data01/tufts/central/dca/MS054/generic
  def directory_for(name)
    File.join(collection_id, 'generic')
  end

  def item_attributes=(items)
    items.each do |key, values|
      new_item = item(key.to_i)
      values.each do |name, val|
        new_item.send("#{name}=".to_sym, val)
      end
    end
  end
end
