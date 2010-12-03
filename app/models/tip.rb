class Tip
  include MongoMapper::Document
  belongs_to :user
  belongs_to :item
  many :votes, :dependent => :destroy
  many :activities, :polymorphic => true, :foreign_key => :source_id, :dependent => :destroy

  key :_type, String 
  key :item_id, String
  key :advice, String
  key :score, Integer, :default => 0
  key :user_id, Integer
  timestamps!
  after_create lambda { |review| Activity.delay.record(review.id, 'Tip') }

  validates_presence_of     :user_id, :advice, :item_id 
end
