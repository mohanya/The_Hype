class ItemComment < Comment
  belongs_to :item
  
  many :activities, :polymorphic => true, :foreign_key => :source_id, :dependent => :destroy
  many :likes, :as => 'object', :dependent => :destroy
  
  key :item_id, String
  
  after_create lambda { |comment| Activity.delay.record(comment.id, 'ItemComment') }
  after_create :delayed_update_item_comment_count
  after_destroy :update_item_comment_count

  def conversation_members
    all_comments = self.root.descendants << self.root
    all_comments.delete(self)
    users_ids = all_comments.map(&:user_id).uniq
    users = User.find_comment_notice_preference(users_ids)
  end

  
  private
  def update_item_comment_count
    item = Item.find(self.item_id)
    item.update_attributes(:comment_count => ItemComment.count(:item_id => self.item_id))
  end

  def delayed_update_item_comment_count
     self.delay.update_item_comment_count
  end
end
