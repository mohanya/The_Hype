module Api
  class CommentsController < BaseResourceController
    
    def index
      if params[:comment_id]    
        @context = Comment.find_by_integer_id(params[:comment_id].to_i)
        comments = Comment.paginate(paging_params.merge(:parent_id => @context.id.to_s, :order => "created_at DESC"))
        @json_context_opts = {
          :methods => [
            :body, 
            :user_name, 
            :user_thumbnail_url, 
            :replies_count,
            :item_integer_id
          ]
        }
        @json_opts = {
          :methods => [
            :body, 
            :user_name, 
            :user_thumbnail_url, 
            :replies_count,
            :item_integer_id,
            :comment_id
          ]
        }
      else
        @json_opts = { 
          :methods => [
            :body, 
            :user_name, 
            :user_thumbnail_url, 
            :replies_count,
            :item_integer_id
          ] 
        }
        @context = Item.find_by_integer_id(params[:item_id].to_i)
        @json_context_opts = {
          :methods => [
            :item_type_tag, 
            :item_type_id,
            :thumbnail_url, 
            :comments_count, 
            :hypes_count,
            :last_hyped,
            :full_description,
            :description_source_url,
            :location,
            :event_time,
            :shares_count,
            :average_metric_ratings
          ]
        }
        comments = Comment.paginate(paging_params.merge(:item_id => @context.id, :parent_id => nil, :order => "created_at DESC"))
      end
      json_objects =  comments.collect { |c| c.as_json(@json_opts) }
      response =  { :paging => json_paging, :objects => json_objects }
      response.merge!(:context => @context.as_json(@json_context_opts || nil)) if @context
      render :json => response
    end
    
    def create
      resource = ItemComment.new
      if params[:comment]   
        item = Item.first(:integer_id => params[:item_id].to_i, :select => 'id')
        resource.item_id = item.id if item
        resource.user_id = params[:comment][:user_id]
        resource.comment_text = params[:comment][:body]
      else #reply
        parent = Comment.first(:integer_id => params[:comment_id].to_i, :select => 'id, item_id')
        resource.parent_id = parent.id if parent
        resource.item_id = parent.item_id
        resource.user_id = params[:reply][:user_id]
        resource.comment_text = params[:reply][:body]
      end
      if resource.save
        render :json => { :success => true, :id => resource.integer_id }
      else
        render :json => { :success => false, :errors => resource.errors.full_messages }
      end
    end
  end
end