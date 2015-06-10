class ImageGeneratingService
  attr_reader :object, :dsid, :mime_type, :quality

  def initialize(object, dsid, mime_type, quality = nil)
    @object = object
    @dsid = dsid
    @mime_type = mime_type
    @quality = quality
  end

  def generate
    path_service = LocalPathService.new(object, dsid)
    path_service.make_directory
    output_path = path_service.local_path
    xfrm = load_image_transformer
    yield(xfrm) if block_given?
    if quality
      xfrm.write(output_path) { self.quality = quality }
    else
      xfrm.write(output_path)
    end

    DerivativeAttachmentService.attach(object, dsid, path_service.remote_url, mime_type)
    output_path
  end

  def generate_resized(long_edge_size)
    generate do |xfrm|
      xfrm.change_geometry!("#{long_edge_size}x#{long_edge_size}") do |cols, rows, img|
       img.resize!(cols, rows)
      end
    end
  end

  private

  def load_image_transformer
    # NOTE tif may not be the only valid extension,
    tiff_path = LocalPathService.new(object, 'Archival.tif', 'tif').local_path
    Magick::ImageList.new(tiff_path)
  end
end
