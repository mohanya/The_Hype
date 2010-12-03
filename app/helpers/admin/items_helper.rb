module Admin::ItemsHelper
  def category_link(item)
    unless item.category.nil?
      link_to item.category.name, edit_admin_item_category_url(item.category) 
    else
      nil
    end
  end
end
