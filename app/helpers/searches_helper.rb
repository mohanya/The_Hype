module SearchesHelper

  def category_search_count_old(query, category_id)
    search_terms = Regexp.new(query.gsub(" or ", "|").gsub(" and ", " ").split(" ").join(".*"), true) 
    
    parent = ItemCategory.find(category_id)
    if parent.children.length > 0
      ids = [parent.id] + parent.children.map(&:id)
      count = Item.count(:search_terms => search_terms, :category_id => {'$in' => ids})
    else
      count = Item.count(:search_terms => search_terms, :category_id => category_id)
    end
    return count.to_s
  end
  
  # This is counting the search hits by category
  def category_search_count(query, category_id)
    # JD: I refactored this into the model
    Item.category_search_count(query, category_id)
  end

end
