class Comment 
  include MongoMapper::Document
  include MongoMapper::Acts::Tree
  # iPhone API
  include CustomJsonSerializer
  include IphoneApiMethods
  
  # key :_id, String
  key :comment_text, String
  key :user_id, Integer
  key :read, Boolean, :default => false
  key :deleted_from_inbox, Boolean, :default => false
  key :user_id_of_parent, Integer, :default => nil
    
  # iPhone API
  key :integer_id, Integer
    
  timestamps!
  many :activities, :polymorphic => true, :foreign_key => :source_id, :dependent => :destroy
  
  validates_presence_of :user_id
  before_create :update_user_id_of_parent
  before_create :set_item_id_of_parent
  before_create :add_integer_id
  after_create :create_notification

  acts_as_tree
    
  def create_notification
     if user_id_of_parent
        comment_item = respond_to?('item_id') ? item_id : (parent and parent.respond_to?('item_id')) ? parent.item_id : nil
        Notice.delay.create(:about => 'Reply', :sender_id => user_id, :user_id  => user_id_of_parent, :item_id => comment_item)
     end
  end

  def user
    User.find(self.user_id)
  end
  
  def children
    Comment.all(:parent_id => self._id.to_s)
  end

  def self.kill_children(id)
    Comment.all(:parent_id => id).collect{|x| x.destroy}
  end

  def delete_from_inbox!
    self.update_attributes({:deleted_from_inbox => true})
  end

  def self.replies_to_comments_by_user_id(user_id, unread_only = false, page = 1, per_page = 10)
    options = { :user_id_of_parent => user_id, :deleted_from_inbox => false, :order => 'created_at desc' }
    options[:read] = false if unread_only
    Comment.paginate(options.merge({:page => page, :per_page => per_page}))
  end


  def update_user_id_of_parent
    self.user_id_of_parent = self.parent ? self.parent.user_id : ''
  end

  def set_item_id_of_parent
    activity = Activity.find_by_id(self.activities.map(&:id))
    if activity and activity.description == "Commented on" and self.item_id == nil
      self.item_id = Comment.find_by_id(self.parent_id).item_id
    end
  end

  def newer_comment
    Comment.last(:deleted_from_inbox => false, :created_at.gt => self.created_at, 
                 :user_id_of_parent => self.user_id_of_parent, :order => 'created_at DESC')
  end
  
  def older_comment
    Comment.first(:deleted_from_inbox => false, :created_at.lt => self.created_at, 
                  :user_id_of_parent => self.user_id_of_parent, :order => 'created_at DESC')
  end

  ###########################
  #
  # iPhone API
  #
  ###########################
  
  def body
    self.comment_text
  end

  def replies_count
    self.children.size
  end
  
  def comment_id
    ItemComment.first(:id => self.parent_id, :select => 'integer_id').integer_id
  end

end
