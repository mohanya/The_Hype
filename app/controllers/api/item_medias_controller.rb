module Api
  class ItemMediasController < BaseResourceController
    def index
      item = Item.find_by_integer_id(params[:item_id].to_i)
      collection = item.medias if item
      @json_opts = { 
        :methods => [
          :caption,
          :item_integer_id,
          :thumbnail_url,
          :large_image_url,
          :small_image_url,
          :integer_id
        ] 
      }
      json_objects =  collection.collect { |c| c.as_json(@json_opts) }
      response =  { :paging => json_paging, :objects => json_objects }
      render :json => response
    end
  end
end