class TuftsImage < TuftsBase

  has_file_datastream 'Thumbnail.png', control_group: 'E'
  has_file_datastream 'Archival.tif', control_group: 'E', original: true
  has_file_datastream 'Advanced.jpg', control_group: 'E'
  has_file_datastream 'Basic.jpg', control_group: 'E'

  def self.default_content_ds
    'Basic.jpg'
  end

  def to_solr(solr_doc=Hash.new, opts={})
    #prefilter perseus and art history objects
    if ['perseus','aah'].any? { |word| pid.include?(word) }
      return solr_doc
    end

    #also filter year book pages and election images
    if ['tufts:UP150','tufts:MS115.001'].any? { |word| pid.starts_with?(word) }
          return solr_doc
    end

    solr_doc = super
    index_sort_fields solr_doc
    index_fulltext solr_doc
    return solr_doc
  end


  def create_derivatives
    create_advanced
    create_basic
    create_thumbnail
    save!
  end

  # Advanced Datastream
  #   The advanced datastream is a high-resolution jpeg file used in the advanced image viewer in the TDL. The advanced datastream is used to generate the basic and thumbnail datastreams.
  #   Format: jpg, high quality (8/12) -- or 69/100
  #   Resolution: Same as archival datastream.
  #   Colorspace: Same as archival datastream.
  #   Pixel dimensions: Same as archival datastream, unless the resulting file is greater than 1 MB. If smaller files are required, set the size of the long side of the image to 1200 pixels.
  def create_advanced
    dsid = 'Advanced.jpg'
    output_path = create_image(dsid, 'image/jpeg', 69)
    original_size_mb = File.size(output_path).to_f / 2**20
    if original_size_mb > 1.0
      create_resized_image(dsid, 1200, 'image/jpeg', 69)
    end
  end


  # Basic Datastream
  #   The basic datastream is a medium-size jpeg used in the TDL interface. It is derived from the advanced datastream.
  #   Format: jpg, maximum quality (12/12) -- or 100/100
  #   Resolution: Same as archival datastream
  #   Colorspace: Same as archival datastream
  #   Pixel dimensions: All basic datastreams MUST be 600 pixels on the long side of the image for proper display in the TDL.
  def create_basic
    create_resized_image('Basic.jpg', 600, 'image/jpeg', 100)
  end

  # Thumbnail Datastream
  #   The thumbnail datastream is a small-size png used in the TDL interface and search results displays.
  #   Format: png, maximum quality (12) -- or 100/100
  #   Resolution: Same as archival datastream
  #   Colorspace: Same as archival datastream
  #   Pixel dimensions: All thumbnail datastream images MUST be 120 pixels on the long side of the image for proper display in the TDL.
  def create_thumbnail
    create_resized_image('Thumbnail.png', 120, 'image/png')
  end


  def create_resized_image(dsid, long_edge_size, mime_type, quality=nil)
    create_image(dsid, mime_type, quality) do |xfrm|
      xfrm.change_geometry!("#{long_edge_size}x#{long_edge_size}") do |cols, rows, img|
       img.resize!(cols, rows)
      end
    end
  end

  def create_image(dsid, mime_type, quality = nil)
    make_directory_for_datastream(dsid)
    output_path = local_path_for(dsid)
    xfrm = load_image_transformer
    yield(xfrm) if block_given?
    if quality
      xfrm.write(output_path) { self.quality = quality }
    else
      xfrm.write(output_path)
    end
    datastreams[dsid].dsLocation = remote_url_for(dsid)
    datastreams[dsid].mimeType = mime_type
    output_path
  end


  def load_image_transformer
    Magick::ImageList.new(local_path_for(original_file_datastream))
  end

  def self.to_class_uri
    'info:fedora/cm:Image.4DS'
  end
end
