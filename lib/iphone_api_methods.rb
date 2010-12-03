module IphoneApiMethods
  
  def add_integer_id
    last = self.class.first(:order => "created_at DESC", :select => 'integer_id')
    unless last and (id = last.integer_id)
      id = 0
    end
    self.integer_id = id + 1
  end
  
  def user_thumbnail_url
    path = self.user.profile.avatar(:thumb)
    if path.first == "/"
      HOST + "/images" + path
    elsif path[0..3] == "http"
      path
    else
      HOST + "/images" + "/" + path
    end
  end
  
  def user_name
    self.user.name
  end
  
  def item_integer_id
    if self.class == Activity
      Item.first(:id => self.source_id_string, :select => 'integer_id').integer_id
    else
      Item.first(:id => self.item_id, :select => 'integer_id').integer_id
    end
  end
  
  def item_name
    if self.class == Activity
      Item.first(:id => self.source_id_string, :select => 'name').name
    else
      Item.first(:id => self.item_id, :select => 'name').name
    end
  end
end