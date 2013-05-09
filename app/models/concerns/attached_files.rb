module AttachedFiles
  extend ActiveSupport::Concern

  included do
    class_attribute :original_file_datastreams
    self.original_file_datastreams = []
  end

  def create_derivatives
  end

  def store_archival_file(dsid, file)
    extension = file.original_filename.split('.').last
    make_directory_for_datastream(dsid)
    File.open(local_path_for(dsid, extension), 'wb') do |f| 
      f.write file.read 
    end

    puts "DSID: #{dsid}"
    ds = datastreams[dsid]
    ds.dsLocation = remote_url_for(dsid, extension)
    ds.mimeType = file.content_type
    create_derivatives
  end

  def make_directory_for_datastream(dsid)
    dir = File.join(local_path_root, directory_for(dsid))
    FileUtils.mkdir_p(dir) unless Dir.exists?(dir)
  end

  def remote_url_for(name, extension)
    File.join(remote_root, file_path(name, extension))
  end

  def local_path_for(name, extension=nil)
    File.join(local_path_root, file_path(name, extension))
  end


  private

  def collection_id
    pid.sub(/.+:([^.]+).*/, '\1')
  end

  def pid_without_namespace
    pid.sub(/.+:(.+)$/, '\1')
  end

  def remote_root
    File.join(Settings.trim_bucket_url, Settings.object_store_path)
  end

  def local_path_root
    File.join(Settings.object_store_root, Settings.object_store_path)
  end

  # Given a datastream name, return the local path where the file can be found.
  # If an extension is provided, generate the path, if the extension is not provided,
  # derive it from the stored dsLocation
  # @example
  #   obj.file_path('Archival.tif', 'tif')
  #   # => /local_object_store/data01/tufts/central/dca/MS054/archival_tif/MS054.003.DO.02108.archival.tif
  def file_path(name, extension=nil)
    File.join(directory_for(name), "#{pid_without_namespace}.#{name.downcase}")
  end

  # Given a datastream name, return the directory path where the file can be found.
  # @example
  #   obj.file_path('Archival.tif')
  #   # => /local_object_store/data01/tufts/central/dca/MS054/archival_tif
  def directory_for(name)
    File.join(collection_id, name.downcase.gsub('.', '_'))
  end

# 2. There are two locations where uploaded files and manifestations end up. We will refer to them as "Tisch" and "DCA".
#   a. You can figure out which is which based on the PID creation
#     i.  If the objects use an automatically created pid, then they are "Tisch" objects.
#     ii. If the objects use a user-supplied PID, then they are "DCA" objects.
#   c. The location of the uploaded file is determined by the object type. The path is NFS mounted on the same system where the server is running, beginning at the location Mike refers to in his e-mail as "bucket".
#     i.      If this is a "Tisch" object then it goes in [bucket]/tufts/sas, and then the appropriate directory as in 2b. above.
#     ii.      If this is a "DCA" object than it goes in [bucket]/tufts/central/dca/[collection #], and then the appropriate directory as in 2b. above.
#         1. "Collection #" is a five digit alphanumeric string (e.g. "MS001"). These five characters are the first five characters in the PID after "tufts:".
#         2. For example, for the PDF with the PID tufts:UA015.012.079.00001, the PDF datastream would go into a directory called [bucket]/tufts/central/dca/UA015/archival_pdf



  module ClassMethods

    # @note this overrides the has_file_datastream method from ActiveFedora::Base
    #   Adding the :original option.
    # @overload has_file_datastream(name, args)
    #   Declares a file datastream exists for objects of this type
    #   @param [String] name 
    #   @param [Hash] args 
    #     @option args :type (ActiveFedora::Datastream) The class the datastream should have
    #     @option args :label ("File Datastream") The default value to put in the dsLabel field
    #     @option args :control_group ("M") The type of controlGroup to store the datastream as. Defaults to M
    #     @option args :original [Boolean] (false) Declare whether or not this datastream contain the preservation master
    #     @option args [Boolean] :autocreate Always create this datastream on new objects
    #     @option args [Boolean] :versionable Should versioned datastreams be stored
    # @overload has_file_datastream(args)
    #   Declares a file datastream exists for objects of this type
    #   @param [Hash] args 
    #     @option args :name ("content") The dsid of the datastream
    #     @option args :type (ActiveFedora::Datastream) The class the datastream should have
    #     @option args :label ("File Datastream") The default value to put in the dsLabel field
    #     @option args :control_group ("M") The type of controlGroup to store the datastream as. Defaults to M
    #     @option args :original [Boolean] (false) Declare whether or not this datastream contain the preservation master
    #     @option args [Boolean] :autocreate Always create this datastream on new objects
    #     @option args [Boolean] :versionable Should versioned datastreams be stored
    def has_file_datastream(*args)
      super
      if args.first.is_a? String 
        name = args.first
        args = args[1] || {}
        args[:name] = name
      else
        args = args.first || {}
      end

      self.original_file_datastreams += [args.fetch(:name, 'content')] if args[:original]
    end

  end



end
