include ActionController::UrlWriter
class Activity
  include MongoMapper::Document
  # iPhone API
  include CustomJsonSerializer
  include IphoneApiMethods
  
  key :source_attr, Hash
  key :user_id, Integer
  key :description, String
  key :desc_for_item, String
  key :activity_date, Time
  key :source_id, ObjectId
  key :source_id_string, String
  key :_type, String
  timestamps!

  belongs_to :item, :foreign_key => :source_id_string
  belongs_to :comment, :foreign_key => :source_id
  belongs_to :favorite, :foreign_key => :source_id, :class_name => "ItemFavorite"
  belongs_to :review, :foreign_key => :source_id
  belongs_to :tip, :foreign_key => :source_id
  many :likes, :as => 'object', :dependent => :destroy
  many :comments, :class_name => "ActivityComment", :dependent => :destroy

  attr_accessor :user_name, :user_path, :user_avatar_url

  def user
    user_id.blank? ? nil : User.find(user_id)
  end
  
  def source
    source_attr.to_mash
  end
    
  def self.get_stream(options={})
    Activity.all(options.merge(:order => "activity_date desc"))
  end
  
  def self.record(source_id, source_type, added = true)
        
    source_obj = source_type.constantize.find(source_id)
    activity = Activity.new
    activity.user_id = source_obj.user_id
    activity.activity_date = source_obj.updated_at
    if !source_obj.is_a?(Item) and source_obj.respond_to?(:item)
      activity.source_id_string = source_obj.item.id 
      activity.source_id = source_obj.id 
    elsif source_obj.is_a?(Item)
      activity.source_id_string = source_obj.id 
    end
    
    case source_obj
      when Review
        description_array=source_obj.item.reviews.map(&:activities).flatten.compact.map(&:description)
        desc_for_item_array=source_obj.item.reviews.map(&:activities).flatten.compact.map(&:desc_for_item)
        if !description_array.include?("First hyped") && !desc_for_item_array.include?("First to Hype it")
          activity.description = "First hyped"
          activity.desc_for_item = "First to Hype it"
        else
          activity.description = "Hyped"
          activity.desc_for_item = "Hyped it"
        end
      when Label
        activity.description = "Tagged"
        activity.desc_for_item = "Tagged this item"
      when Tip
        activity.description = "Added tip to"
        activity.desc_for_item = "Added a Tip"
      when ItemComment
        if source_obj.parent_id
          activity.description = "Commented on"
          activity.desc_for_item = "Posted a comment"
        else
          activity.description = "Commented on"
          activity.desc_for_item = "Started a conversation"
        end
      when Item
        activity.description = "Added" 
        activity.desc_for_item = "Added this item"
      when ItemFavorite
        if added
          activity.description = "Favorited"        
          activity.desc_for_item = "Favorited this item"
        else
          activity.description = "Unfavorited"        
          activity.desc_for_item = "Unfavorited this item"
        end
    end    
    
    activity.save        
  end
  
  ####################
  #
  # iPhone API
  #
  ####################
  
  def activity_user_name
    self.user.name
  end
  
  def item_type_tag
    Item.first(:id => self.source_id_string, :select => 'category_id').category.name
  end
  
  def item_thumbnail_url
    Item.first(:id => self.source_id_string, :select => 'id').thumbnail_url
  end
  
  def text
    item_name = Item.first(:id => self.source_id_string, :select => 'name').name
    return self.description + " " + item_name
  end

end
