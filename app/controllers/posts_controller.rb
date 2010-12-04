class PostsController < ApplicationController
  before_filter :enabled?
  
  def index
    @page = params[:page] || 1
    @posts = Post.published.paginate(:page => @page, :per_page => 10)
    @controller_name = "Blog"
    respond_to do |format|
      format.html
      format.atom { render :layout => false }
    end
  end

  def show
    @controller_name = "Blog"
    @flipped = true
    @post = Post.published.find(params[:id])
    redirect_to @post, :status => 301 and return if @post.has_better_id?
    @title_item = @post.title
    respond_to do |format|
      format.html
    end
  end
  
  def search
    @title_item = "Search results for #{params[:query]}"
    @controller_name = "Blog"
    @page = params[:page] || 1
    @posts = Post.search(params[:query], :page => @page, :conditions => {:state => "published"})
    respond_to do |format|
      format.html { render :action => :index }
    end
  end
  
  protected
  
  def enabled?
    @site = SiteSetting.find(:first)
    @site.allow_blog ? true : (render :file => "public/404.html", :status => 404)
  end

end
