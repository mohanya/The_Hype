class Inbox::CommentsController < ApplicationController  
  before_filter :login_required

  layout "profile.html.haml"
  def show
    @comment = Comment.first(:id => params[:id], :user_id_of_parent => current_user.id)
    @comment.update_attributes({:read => true})

  end

  def unread
    @comments = Comment.replies_to_comments_by_user_id(current_user.id, true, params[:page], 5)

    respond_to do |format|
      format.html { render :action => :index } 
    end
  end
  def index
    @comments = Comment.replies_to_comments_by_user_id(current_user.id, false, params[:page], 5)
    respond_to do |format|
      format.html # index.html.erb
    end
  end
  # DELETE /messages/1
  # DELETE /messages/1.xml
  def destroy
    
    @comment = Comment.find(params[:id])
    next_comment = params[:from_show] ? @comment.older_comment : nil
    @comment.delete_from_inbox!

    respond_to do |format|
      format.html do
        if next_comment
          redirect_to(inbox_comment_url(next_comment))
        else
          redirect_to(inbox_comments_url)
        end
      end
      format.xml  { head :ok }
    end
  end

  def create
    @original_comment = Comment.find(params[:old_comment_id])
    @commentable =  @original_comment.item
    @comment = @commentable.comments.build(params[:comment])
    @comment.parent =  @original_comment
    @comment.user_id = current_user.id
    respond_to do |format|
      if @comment.save
        format.html { 
            flash[:notice] = 'Comment was successfully created.'
            redirect_to(inbox_comments_url) 
            }
        format.js   { render :text => "<div class='notice_message'>Comment was successfully created</div>"}
      else
        format.html { render :action => "new" }
        format.js   { render :action => "new", :layout => false }
      end
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
    @ids = (params[:scope] == 'friends') ? current_user.friend_ids : []
    options = {:parent_id => nil, :per_page => 10, :page => params[:comments]}
    @comments = @ids.empty?  ? @item.comments.paginate(options) : @item.comments.paginate(options.merge(:user_id.in => @ids))
    @commentable = @item
    render :partial => 'items/conversation_block', :object  => @comments
  end
end
