module Api
  class FavoritesController < BaseResourceController
    
    def create
      item = Item.find_by_integer_id(params[:item_id].to_i, :select => 'id, category_id')
      resource = ItemFavorite.first(:item_id => item.id, :user_id => params[:favorite][:user_id]) if item
      unless resource
        resource = ItemFavorite.new
        resource.item_id = item.id
        resource.user_id = params[:favorite][:user_id] 
        resource.item_category_id = item.category_id
        resource.favorite = true
        resource.save
        render :json => { :success => true, :id => resource.id }
      else
        render :json => { :success => false, :errors => 'Item already favorited!' }
      end
    end
  
  end
end