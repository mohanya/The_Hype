class Like 
  include MongoMapper::Document

  belongs_to :user
  belongs_to :object , :polymorphic => true
  validates_uniqueness_of   :user_id, :scope => :object_id

  key :_id, String 
  key :object_id, ObjectId
  key :object_type, String
  key :user_id, Integer
  timestamps!
end
