# Settings specified here will take precedence over those in config/environment.rb

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes = false
config.after_initialize do
  Sass::Plugin.options[:line_comments] = false
end

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and
config.action_controller.consider_all_requests_local = true
config.action_view.debug_rjs                         = true

# enabling caching for caching test
config.action_controller.perform_caching             = true

# Don't care if the mailer can't send
config.action_mailer.raise_delivery_errors = false
config.action_mailer.perform_deliveries = true
config.action_mailer.delivery_method = :smtp

AAWS_API_KEY = "086B24GKBJHVD8E79Z02"
ENV['PATH'] = "#{ENV['PATH']}:/usr/local/bin"

# TODO this is temporary
HOST = "http://192.168.1.150:3000"
