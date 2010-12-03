class ItemCategory
  include MongoMapper::Document
  include FriendlyUniqueId
  include MongoMapper::Acts::Tree
  include IphoneApiMethods
  
  has_friendly_unique_id :name  
  
  many :items
  
  key :_id, String 
  key :name, String
  key :description, String
  key :tag_name, String
  key :api_source, String, :in => AppSetting.api_sources
  key :integer_id, Integer # iPhone API
  acts_as_tree
  timestamps!
  
  # iPhone API
  before_create :add_integer_id
  
end
