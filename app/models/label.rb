class Label
  include MongoMapper::Document
  
  belongs_to :user
  belongs_to :item
  belongs_to :review
  
  key :user_id, Integer # this is inteneded to refer to the user who applied the tag.
  key :item_id, String
  key :review_id, ObjectId
  timestamps!
  
  # this is kind of a tag for the tags...
  key :type, String #i.e. Pro or Con. I left this flexible so we can add other types of tags...
  key :tag, String
  
  after_save :reindex_item
  after_create :update_label_stats
  
  def self.create_labels(item_id, user_id, tags_string)
    if tags_string and (tags = tags_string.split(',').map {|c| c.strip})
       for tag in tags
         Label.create(:item_id => item_id, :user_id => user_id, :tag => tag)
       end
    end
  end

  def self.create_many_with_type(review_id, item_id, user_id, type, list) 
    if list and tags = list.split(',').map {|c| c.strip}
      for tag in tags
        Label.create(:review_id => review_id, :user_id => user_id, :item_id => item_id, :tag => tag, :type => type)
      end
    end
  end
  
  private
  def log_it
    puts STDOUT, "saving now \n\n"
  end

  def add_tags_to_search
    if (Label.first(:tag => self.tag, :item_id => self.item_id)).nil?
      if item = Item.find(self.item_id)
        item.search_terms = item.search_terms + ' ' + self.tag
        item.save
      end
    end
  end

  def reindex_item
    if item = Item.find(self.item_id)
      item.reindex_sunspot
    end
  end
  
  def update_label_stats
    stat = LabelStat.first(:item_id => self.item_id, :type => self.type, :tag => self.tag)
    if stat
      stat.value += 1 
      stat.save
    else
      LabelStat.create(:item_id => self.item_id, :type => self.type, :tag => self.tag, :value => 1)
    end
  end  
  
end
