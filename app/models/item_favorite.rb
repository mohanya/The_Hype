class ItemFavorite 
  include MongoMapper::Document
    
  belongs_to :item
  many :activities, :polymorphic => true, :foreign_key => :source_id, :dependent => :destroy
  
  key :item_id, String
  key :user_id, Integer
  key :favorite, Boolean
  key :item_category_id
  timestamps!
  
  after_save lambda { |favorite| Activity.delay.record(favorite.id, 'ItemFavorite', favorite.favorite) }
    
  def user
    User.find(self.user_id)
  end

  def self.set_category
    for favorite in  ItemFavorite.all
      favorite.item_category_id = favorite.item.category_id
      favorite.save
    end
  end
  
  def self.add_to_favorites(items,user)
     unless items.empty?
      items.each do |k,v|
        item_fav=ItemFavorite.first(:user_id=>user.id,:item_id=>v)
        if !item_fav && i = Item.find_by_id(v)
          ItemFavorite.create(:user_id => user.id, :item_id => i.id, :favorite=>true, :item_category_id=>k)
        elsif item_fav && item_fav.favorite==false
          item_fav.favorite=true
          item_fav.save
        end
      end
    end
      user.delete_cache
  end
end
