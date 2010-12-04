require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::UsersController do
  fixtures :users, :profiles
  
  before(:all) do
    User.default_url_options[:host] = 'test.host'
  end
  after(:all) do
    User.default_url_options[:host] = nil
  end

  before do
    login_as(:josh)
  end

  describe "GET 'index'" do
    it "should be successful" do
      get :index
      response.should be_success
    end
  end

  describe "GET 'show'" do
    it "should be successful" do
      get :show, :id => "1"
      response.should be_success
    end
  end

  describe "GET 'edit'" do
    it "should be successful" do
      get :edit, :id => "1"
      response.should be_success
    end
  end

  describe "PUT 'update'" do
    
    describe "on success" do
      before(:each) do
        put :update, :id => "3", :user => {:login => "josh1", :email => "josh@example.com", :profile_attributes => {:first_name => "Josh", :last_name => "doe", :gender => 'Male', :birth_date => 25.years.ago}}
      end
    
      it "should redirect" do
        response.should be_redirect
      end
    
      it "should update the profile" do
        users(:josh).reload.login.should == "josh1"
        users(:josh).profile.reload.first_name.should == "Josh"
      end
    end
    
    describe "on failure" do
      it "should re-render" do
        put :update, :id => "3", :user => {:login => "quentin", :email => "josh@example.com"}
        response.should_not be_redirect
        response.should render_template("admin/users/edit")
      end
    end
  end

  describe "DELETE 'destroy'" do
    it "should be successful" do
      get :destroy, :id => users(:aaron).id
      response.should redirect_to(admin_users_url)
    end
  end

  describe "POST 'make_admin'" do
    
    def do_post
      post :make_admin, :id => users(:quentin).id
    end
    
    it "should be successful" do
      do_post
      response.should be_redirect
    end
    
    it "should find the requested user and promote it" do
      do_post
      users(:quentin).reload.should be_admin
    end
    
  end
  
  describe "POST 'activate'" do
    
    def do_post
      post :activate, :id => users(:aaron).id
    end
    
    it "should be successful" do
      do_post
      response.should redirect_to(admin_users_url)
    end
    
    it "should find the requested user and activate it" do
      do_post
      users(:aaron).reload.should be_active
    end
    
  end
  
  describe "POST 'remove_admin'" do
    
    def do_post
      post :remove_admin, :id => users(:josh).id
    end
    
    it "should be successful" do
      do_post
      response.should be_redirect
    end
    
    it "should find the requested user and demote it" do
      do_post
      users(:josh).reload.should_not be_admin
    end
    
  end
  
  describe "state tracking" do

    it 'suspends a user if you are logged in as an admin' do
      put :suspend, :id => users(:quentin).id
      users(:quentin).reload.should be_suspended
      response.should redirect_to("admin/users")
    end

  end
  
end



describe Admin::UsersController, "requires an admin" do
  
  describe "GET 'index'" do
    
    it "should fail without being logged in as an admin" do
      get :index
      flash[:warning].should == "You need admin privileges for that."
      response.should_not be_success
    end
  end
  
end
