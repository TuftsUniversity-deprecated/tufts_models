config = YAML::load(ERB.new(IO.read(File.join(Rails.root, 'config', 'redis.yml'))).result)[Rails.env].with_indifferent_access
Resque.redis = Redis.new(host: config[:host], port: config[:port], thread_safe: true)
Resque::Plugins::Status::Hash.expire_in = (7 * 24 * 60 * 60) # makes statuses go away in 1 week


unless Resque.inline?
  require 'active_support/lazy_load_hooks'
  ActiveSupport.on_load :active_record do
    require 'resque'
    Resque.before_fork do |job|
      ActiveRecord::Base.clear_all_connections!
    end
  end
end

# if defined?(PhusionPassenger)
#   PhusionPassenger.on_event(:starting_worker_process) do |forked|
#     # We're in smart spawning mode.
#     if forked
#       # Re-establish redis connection
#       require 'redis'
#       config = YAML::load(ERB.new(IO.read(File.join(Rails.root, 'config', 'redis.yml'))).result)[Rails.env].with_indifferent_access
# 
#       # The important two lines
#       $redis.client.disconnect if $redis 
#       $redis = Redis.new(host: config[:host], port: config[:port], thread_safe: true) rescue nil
#       Resque.redis.client.reconnect if Resque.redis
#     end
#   end
# else
#   config = YAML::load(ERB.new(IO.read(File.join(Rails.root, 'config', 'redis.yml'))).result)[Rails.env].with_indifferent_access
#   $redis = Redis.new(host: config[:host], port: config[:port], thread_safe: true) rescue nil
# end
