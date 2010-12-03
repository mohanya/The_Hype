class UserTop 
  include MongoMapper::Document
    
#  belongs_to :item, :class_name => "Item"
#  belongs_to :user, :class_name => "User"
  
  validates_presence_of :user_id
  validates_presence_of :item_id

  key :item_id, String
  key :user_id, Integer
  timestamps!
  
  def user
    User.find(self.user_id)
  end

  def item
    Item.find(self.item_id)
  end

  def self.create_or_update(items, user)
    UserTop.find_all_by_user_id(user.id).each{|e| e.destroy}

    unless items.empty?
      items.each do |k,v|
        if i = Item.find_by_id(v)
          UserTop.create(:user_id => user.id, :item_id => i.id)
        end
      end
      user.delete_cache
    end
  end

end
