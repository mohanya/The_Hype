module Users::FavoritesHelper
  def find_item_for_category(cat, items)
    children_ids = cat.children.collect{|e| e.id} 
    item = nil
    children_ids.each do |e|
      if items[e] and items[e].class.name == "UserTop"
        item = items[e]
        break 
      end
    end
    return item
  end

end
