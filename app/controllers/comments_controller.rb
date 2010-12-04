class CommentsController < ApplicationController  
  before_filter :login_required
  
  def create
    return if params[:comment_text].blank?
    @commentable = params[:commentable_type].capitalize.constantize.find(params[:commentable_id])
    @parent_comment = params[:comment_type].constantize.find(params[:parent_comment_id]) if (params[:parent_comment_id] && !params[:parent_comment_id].blank?)
    @comment = @commentable.comments.build
    @comment.parent = @parent_comment if !params[:parent_comment_id].blank?
    @comment.user_id = current_user.id
    if request.post? #form submitted
      @comment.comment_text = params[:comment_text]
      if @comment.save
        if @commentable.is_a?(Item)
          render :partial => 'items/conversation', :object => @comment
        else
          render :partial => 'activities/reply', :object => @comment
        end
      else
        render :text => 'Comments cannot exceed 3000 characters', :status => :unprocessible_entity
      end
    else #GET - display the form
      render :partial => 'conversation_form'
    end
  end
  
  def get_form
    @item = Item.find(params[:id])
    @parent_comment = Comment.find(params[:parent_comment_id]) if !params[:parent_comment_id].blank?
    @comment = @item.comments.build
    @comment.parent = @parent_comment if !params[:parent_comment_id].blank?
    @comment.user_id = current_user.id
    @commentable = @item
    render :partial => 'items/conversation_form'
  end

  def list
    @item = Item.find(params[:item_id])
    @ids = (params[:scope] == 'friends') ? current_user.friend_ids : false
    options = {:parent_id => nil, :per_page => 10, :page => params[:comments]}
    @comments = @ids ? @item.comments.paginate(options.merge(:user_id.in => @ids)) : @item.comments.paginate(options)
    @commentable = @item
    render :partial => 'items/conversation_block', :object  => @comments
  end

  
end
