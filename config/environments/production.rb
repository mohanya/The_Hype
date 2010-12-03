# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

config.after_initialize do
  Sass::Plugin.options[:never_update] = true
end

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = true
config.action_controller.perform_caching             = true

# Enable serving of images, stylesheets, and javascripts from an asset server
# config.action_controller.asset_host                  = "http://assets.example.com"

# Disable delivery errors, bad email addresses will be ignored
# config.action_mailer.raise_delivery_errors = false
config.action_mailer.delivery_method = :smtp

# mem_cache config options for ref
# Use the memcached store with default options (localhost, TCP port 11211)
# config.cache_store = :mem_cache_store
# Use the memcached store with an options hash
#config.cache_store = :mem_cache_store, 'localhost', '192.168.1.1:1001', { :namespace => 'test' }
#config.cache_store = :mem_cache_store, Memcached::Rails.new

HOST = "http://www.thehype.com"
