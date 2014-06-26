class DownloadsController < ApplicationController
  include Hydra::Controller::DownloadBehavior
  def send_content
    send_file asset.local_path_for(params[:datastream_id]), content_options
  end    

  # Create some headers for the datastream
  def content_options
    {disposition: 'inline', type: datastream.mimeType, filename: datastream_name}
  end

  def datastream_name
    File.basename(asset.local_path_for(params[:datastream_id]))
  end
end
