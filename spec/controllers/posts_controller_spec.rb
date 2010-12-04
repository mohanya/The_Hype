require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PostsController do
  
  before do
    @site = site_settings(:site)
  end
  
  describe "with allow_blog turned off" do
    before do
      @site.allow_blog = false
      @site.save
    end
    
    it "should throw a 404" do
      get :index
      response.headers["Status"].should be_nil
    end
  end
  
  describe "with allow_blog turned on" do
    before do
      @site.allow_blog = true
      @site.save
      @post = Factory(:post, :state => "published")
    end
    
    it "should be able to get the index of posts" do
      get :index
      response.should be_success
    end
    
    it "should be able to get to an individual post" do
      get :show, :id => @post.to_param
      response.should be_success
    end
    
    it "should redirect if using the wrong 'permalink'" do
      get :show, :id => @post.id
      response.should be_redirect
    end
    
    it "should allow a visitor to search blog posts" do
      Post.should_receive(:search).and_return([@post])
      post :search, :query => "Joe Sixpack"
      response.should be_success
      response.should render_template("posts/index")
    end
    
  end

end
