module TuftsFileAssetsHelper

  def convert_url_to_local_path(url)
    local_object_store = Settings.local_object_store

    if local_object_store.match(/^\#\{Rails.root\}/)
      local_object_store = "#{Rails.root}" + local_object_store.gsub("\#\{Rails.root\}", "")
    end

    url = local_object_store + url.gsub(Settings.trim_bucket_url, "")

    return url
  end

  def send_datastream_inline(datastream)
    content = datastream.content

    response.header["Content-Length"] = (datastream.size == 0) ? content.to_s.bytesize.to_s : datastream.size

    self.send_data content, :filename => datastream.dsLabel, :type => datastream.mimeType, :disposition => 'inline'
  end
end
