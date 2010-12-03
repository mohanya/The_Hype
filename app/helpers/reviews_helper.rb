module ReviewsHelper

  def criteria_1(item_id)
    item = Item.first(:id => item_id, :select => 'category_id, id')
    case item.category.api_source
      when "person"
        criteria = ['Image',  "Level of impression the item presents"]
      else
        criteria = ['Quality', 'Degree of excellence of the item']
    end
    return criteria
  end
  
  def criteria_2(item_id)
    item = Item.first(:id => item_id, :select => 'category_id, id')
    case item.category.api_source
      when "product"
        criteria = ['Value',  "Worth of an item compared to price paid"]
      when "music-artist"
        criteria = ['Talent', "Level of skill or aptitude of the item"]
      when "music-album"
        criteria = ['Talent', "Level of skill or aptitude of the item"]
      when "music-track"
        criteria = ['Talent', "Level of skill or aptitude of the item"]
      when "movie"
        criteria = ['Value', 'Worth of an item compared to price paid']
      when "event"
        criteria = ['Value', 'Worth of an item compared to price paid']
      when "person"
        criteria = ['Appeal', "Level of interest or attraction for the item"]
      when "place"
        criteria = ['Value', 'Worth of an item compared to price paid']
      when "web"
        criteria = ['Appeal', "Level of interest or attraction for the item" ] 
      else
        criteria = ['Value',  "Worth of an item compared to price paid"]
    end
    
    return criteria
  end
  
  def criteria_3(item_id)
    item = Item.first(:id => item_id, :select => 'category_id, id')
    case item.category.api_source
      when "product"
        criteria = 'Utility',  "How useful, beneficial, functional an item is"
      when "music-artist"
        criteria = 'Appeal', "Level of interest or attraction for the item"
      when "music-album"
        criteria = 'Appeal', "Level of interest or attraction for the item"
      when "music-track"
        criteria = 'Appeal', "Level of interest or attraction for the item"
      when "movie"
        criteria = 'Appeal', 'Level of interest or attraction for the item'
      when "event"
        criteria = 'Utility', 'How useful, beneficial, functional an item is'
      when "person"
        criteria = 'Talent', "Level of skill or aptitude of the item"
      when "place"
        criteria = 'Appeal', "Level of interest or attraction for the item"
      when "web"
        criteria = 'Utility', "How useful, beneficial, functional an item is"
      else
        criteria = 'Utility',  "How useful, beneficial, functional an item is"
    end
    
    return criteria
  end
  
end
