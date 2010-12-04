$LOAD_PATH.unshift File.dirname(__FILE__) + "/../lib"
require "rubygems"
require "spec"
require "sham"

module Spec
  module MongoMapper
    def self.configure!
      ::MongoMapper.database = "machinist_mongomapper"

      Spec::Runner.configure do |config|
        config.before(:each) { Sham.reset }
        config.after(:all)   { ::MongoMapper.database.collections.each { |c| c.remove } }
      end
    end
  end
end