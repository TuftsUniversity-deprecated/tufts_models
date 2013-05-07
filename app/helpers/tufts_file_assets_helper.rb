module TuftsFileAssetsHelper

  def convert_url_to_local_path(url)
    Settings.object_store_root + url.gsub(Settings.trim_bucket_url, "")
  end

  # def send_datastream_inline(datastream)
  #   content = datastream.content

  #   response.header["Content-Length"] = (datastream.size == 0) ? content.to_s.bytesize.to_s : datastream.size

  #   self.send_data content, :filename => datastream.dsLabel, :type => datastream.mimeType, :disposition => 'inline'
  # end
end
