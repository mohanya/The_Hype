class Essential 
  include MongoMapper::Document
    
  belongs_to :item
  
  key :item_id, String
  key :user_id, Integer  
  key :essential_category, String
  timestamps!
  
  def self.essential_categories 
    ['Computer', 'Mobile device', 'Ride']
  end
  
  def item_name
    self.item.name || ''
  end
  
  def user
    User.find(self.user_id)
  end
  
end
