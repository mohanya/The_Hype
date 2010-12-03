class Admin::PostsController < AdminController
  before_filter :find_post, :except => [:index, :new, :create]
  
  def index
    @posts = Post.find(:all)
    respond_to do |format|
      format.html
    end
  end

  def new
    @post = Post.new
    respond_to do |format|
      format.html
      format.js { render :layout => false }
    end
  end

  def create
    @post = Post.new(params[:post])
    @post.author = current_user
    respond_to do |format|
      if @post.save
        flash[:notice] = "Your blog post has been saved."
        format.html { redirect_to admin_posts_url }
      else
        flash[:warning] = "There was an issue saving your blog post."
        format.html { render :action => :new }
      end
    end
  end

  def edit
  end
  
  def update
    respond_to do |format|
      if @post.update_attributes(params[:post])
        flash[:notice] = "Your blog post has been updated."
        format.html { redirect_to admin_posts_url }
      else
        flash[:warning] = "There was an issue updating your blog post."
        format.html { render :action => :edit }
      end
    end
  end

  def destroy
  end
  
  protected
  
  def find_post
    @post = Post.find(params[:id])
  end

end
