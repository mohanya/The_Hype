require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::PostsController do
  fixtures :users
  
  before(:each) do
    login_as(:josh)
  end

  describe "GET 'index'" do
    it "should be successful" do
      get :index
      response.should be_success
    end
  end

  describe "GET 'new'" do
    it "should be successful" do
      get :new
      response.should be_success
    end
  end

  describe "POST 'create'" do
    it "should be successful" do
      post :create, :post =>{ :body => "Test", :title => "Test", :state => "draft"}
      response.should be_redirect
    end
    
    it "should fail if something is missing" do
      post :create, :post => { :body => "Test" }
      response.should_not be_redirect
    end
    
    it "should create a post" do
      lambda {
        post :create, :post =>{ :body => "Test", :title => "Test", :state => "draft"}
      }.should change(Post, :count)
    end
  end

  describe "GET 'edit'" do
    before do
      @post = Factory(:post)
    end
    
    it "should be successful" do
      get :edit, :id => @post.id
      response.should be_success
    end
  end
  
  describe "PUT 'update'" do
    
    before do
      @post = Factory(:post)
    end
    
    it "should be successful" do
      put :update, :id => @post.id, :post =>{ :title => "Test" }
      response.should be_redirect
    end
    
    it "should fail if something is missing" do
      put :update, :id => @post.id, :post => { :title => nil }
      response.should_not be_redirect
    end
  end

  # describe "GET 'destroy'" do
  #   it "should be successful" do
  #     delete 'destroy'
  #     response.should be_success
  #   end
  # end
end
