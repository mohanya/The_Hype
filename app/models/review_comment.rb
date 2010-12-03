class ReviewComment < Comment
  belongs_to :review
  
  many :activities, :polymorphic => true, :foreign_key => :source_id, :dependent => :destroy
  
  key :review_id, String
  
  acts_as_tree
  
  after_create lambda { |comment| Activity.delay.record(comment.id, 'ReviewComment') }

end
