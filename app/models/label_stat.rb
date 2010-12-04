class LabelStat
  include MongoMapper::Document
  include CustomJsonSerializer
  include IphoneApiMethods
  
  belongs_to :item
  
  key :tag, String
  key :value, Integer
  key :type, String # pro or con
  key :item_id, String
  key :integer_id, Integer
  timestamps!
  
  before_create :add_integer_id
    
  def text
    self.tag
  end
  
  def count
    self.value
  end
  
end