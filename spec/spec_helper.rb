# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
#require File.dirname(__FILE__) + "/../config/environment"
require 'spec'
require 'spec/rails'
#require File.dirname(__FILE__) + '/spec_factory'
#require File.dirname(__FILE__) + '/blueprints'
require 'fakeweb'
require 'ruby-debug'
require 'be_valid'

FakeWeb.allow_net_connect = false

MongoMapper.database = "the_hype_test"

def fixture_file(filename)
  return '' if filename == ''
  #file_path = File.dirname(__FILE__) + '/fixtures/' + filename
  file_path = File.expand_path(File.dirname(__FILE__) + '/fixtures/' + filename)
  File.read(file_path)
end
 
def shopping_url(url)
 url =~ /^http/ ? url : "http://sandbox.api.shopping.com/publisher/3.0/rest#{url}"
end

def stub_get(url, filename, status=nil)
  options = {:body => fixture_file(filename)}
  options.merge!({:status => status}) unless status.nil?
  
  FakeWeb.register_uri(:get, url, options)
end
 
def stub_post(url, filename)
  FakeWeb.register_uri(:post, shopping_url(url), :body => fixture_file(filename))
end 
 
def reset_test_db!
  MongoMapper.connection.drop_database("the_hype_test")
end

include AuthenticatedTestHelper

require 'shoulda'

Spec::Runner.configure do |config|
  # If you're not using ActiveRecord you should remove these
  # lines, delete config/database.yml and disable :active_record
  # in your config/boot.rb
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  config.fixture_path = RAILS_ROOT + '/spec/fixtures/'
  config.global_fixtures = :site_settings

  config.before(:all)    { reset_test_db! }
  config.before(:each)   { Sham.reset }


  def add_items
    product_cat = ItemCategory.make(:name => "Product", :api_source => AppSetting.api_sources[1])
    music_cat = ItemCategory.make(:name => "Music", :api_source => AppSetting.api_sources[7])
    music_artist_cat = ItemCategory.make(:id => "music-artist", :name => "Artist", :api_source => AppSetting.api_sources[8], :parent_id => music_cat.id)
    Item.make(:name => 'ipod', :category_id => product_cat.id)
    Item.make(:name => 'zen', :category_id => product_cat.id)
    Item.make(:name => 'porter ricks', :category_id => music_artist_cat.id)
              

=begin
    Item.make(:name => 'blade runner', 
              :category_id => ItemCategory.make(:name => 'Movie', :api_source => AppSetting.api_sources[3]).id)
=end
  end
  
  # == Fixtures
  #
  # You can declare fixtures for each example_group like this:
  #   describe "...." do
  #     fixtures :table_a, :table_b
  #
  # Alternatively, if you prefer to declare them only once, you can
  # do so right here. Just uncomment the next line and replace the fixture
  # names with your fixtures.
  #
  # config.global_fixtures = :table_a, :table_b
  #
  # If you declare global fixtures, be aware that they will be declared
  # for all of your examples, even those that don't use them.
  #
  # You can also declare which fixtures to use (for example fixtures for test/fixtures):
  #
  config.fixture_path = RAILS_ROOT + '/spec/fixtures/'
  #
  # == Mock Framework
  #
  # RSpec uses it's own mocking framework by default. If you prefer to
  # use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  #
  # == Notes
  # 
  # For more information take a look at Spec::Example::Configuration and Spec::Runner
end
