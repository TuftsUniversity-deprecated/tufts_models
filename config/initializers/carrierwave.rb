CarrierWave.configure do |config|
  config.root = Rails.root.join("uploads", Rails.env)
  # this is where files are stored so the user doesn't have to re-upload the file when a
  # form is redisplayed
  config.cache_dir = 'cache'
end
