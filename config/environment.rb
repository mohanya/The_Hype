# Be sure to restart your server when you modify this file

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.4' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.
  # See Rails::Configuration for more options.

  # Skip frameworks you're not going to use (only works if using vendor/rails).
  # To use Rails without a database, you must remove the Active Record framework
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Only load the plugins named here, in the order given. By default, all plugins 
  # in vendor/plugins are loaded in alphabetical order.
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_resquirement, :all ]

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )
  
  # GEMS
  
  config.gem 'httparty',           :version => '>=0.5.0'
  config.gem 'haml',               :version => '3.0.9'
  config.gem 'compass',            :version => '0.10.2'
  config.gem "chronic",            :version => '0.2.3'
  config.gem 'will_paginate',      :version => '2.3.12'
  config.gem 'whenever',           :version => '0.4.2'
  config.gem "friendly_id",        :version => '2.1.1'
  #config.gem 'gluestick',          :version => '0.3.1', :lib => false
  #config.gem "newrelic_rpm"
  config.gem "tinder", :lib => false
  config.gem "vlad",               :version => '2.0.0', :lib => false
  config.gem "liquid",             :version => '1.9.0'
  config.gem "campaign_monitor",   :version => '0.1.1'
  # APP GEMS
  config.gem 'bluecloth',          :version => '2.0.7'
  # config.gem 'searchlogic',        :version => '2.4.14'
  config.gem 'twitter',            :version => '0.9.7'
  config.gem 'acts-as-taggable-on',:version => '2.0.4'
  config.gem 'hpricot',            :version => '0.8.2'
  config.gem 'contacts',           :version => '1.2.3'
  #config.gem 'json_pure',          :version => '1.2.0'
  
  # config.gem 'mongo',              :version => '1.0'
  config.gem 'mongo_mapper',       :version => '0.8.3'
  config.gem 'mm-nested-attributes', :version => '0.1.0'
  config.gem 'shoppr',             :version => '0.2.3'
  config.gem 'scrobbler', :lib => 'scrobbler'
  config.gem 'roxml',              :version => '2.5.3'
  config.gem 'stringex',           :version => '1.1.0'
  config.gem 'aws-s3',             :version => '0.6.2', :lib => 'aws/s3'
  config.gem 'right_aws',          :version => '1.1.0'
  config.gem 'googlecharts',       :version => '1.5.4', :lib => 'gchart'
  config.gem 'fastercsv',          :version => '1.5.3'
  config.gem 'ramdiv-mongo_mapper_acts_as_tree', :version => '0.0.5', :lib => 'mongo_mapper_acts_as_tree'
  config.gem 'upcoming-events',    :version => '0.0.1', :lib => 'upcoming'
  config.gem 'tmdb_party',         :version => '0.4.1'

  config.gem 'cloudfiles',          :version => '1.4.7'
  config.gem 'carrierwave',         :version => '0.4.5'
  config.gem 'mini_magick',         :version => '1.2.5'

  # for ip geolocation
  config.gem 'geo_ip',               :version => '0.3.0'
  
  # For google AJAX image search
  config.gem 'googleajax',          :version => '1.0.1'
  
  # Facebook Graph Gem
  config.gem 'fgraph' #,              :version => "0.3.0"
  
  config.gem 'memcached'#,           :version => '0.19.6'

  
  # Search / Sunspot / Solr
  config.gem 'websolr-sunspot_rails'
  
  # iPhone API
  config.gem 'inherited_resources', :version => '0.9.2'
  

  
  #config.gem 'utility_scopes', :version => '>= 0.3.1', :source => 'http://github.com/yfactorial/utility_scopes.git'
  
  # Force all environments to use the same logger level
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Your secret key for verifying cookie session data integrity.
  # If you change this key, all old sessions will become invalid!
  # Make sure the secret is at least 30 characters and all random, 
  # no regular words or you'll be exposed to dictionary attacks.
  config.action_controller.session = {
    :session_key => '_handcrafted_session',
    :secret      => '2f6e90d4e3a3f9c3026a9e5f0800eb9dd9035420237bf55ccca91711b4708b883639f8f740671959b7cefef75efa1c1a5d02674772abd14359dd2a5307a2e453'
  }

  config.load_paths += %W(#{RAILS_ROOT}/app/concerns #{RAILS_ROOT}/app/jobs)

  # Use the database for sessions instead of the cookie-based default,
  # which shouldn't be used to store highly confidential information
  # (create the session table with 'rake db:sessions:create')
  # config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector
  config.active_record.observers = :user_observer, :invite_observer, :subscription_observer

  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc
  config.time_zone = "Eastern Time (US & Canada)"
  
end

class Array
  def average
    inject(0.0) { |sum, e| sum + e } / length
  end
  
  def count
    size
  end
end
