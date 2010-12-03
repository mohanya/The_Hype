require File.dirname(__FILE__) + '/../spec_helper'

describe PasswordsController do
  fixtures :users
  
  before(:all) do
    User.default_url_options[:host] = 'test.host'
  end
  after(:all) do
    User.default_url_options[:host] = nil
  end
  

  describe "GET 'new'" do
    it "should be successful" do |variable|
      get :new
      response.should be_success      
    end
  end
 
  describe "POST 'create'" do
    it "should be successful" do
      user = users(:josh)
      User.should_receive(:find_by_login).and_return(nil)
      User.should_receive(:find_by_email).and_return(user)
      UserMailer.should_receive(:deliver_forgot_password)
      user.should_receive(:make_password_reset_code)
      post :create, :login_or_email => "josh@example.com"
      response.should redirect_to(login_url)
    end
  end

  describe "GET 'edit'" do
    it "should be successful" do
      user = users(:josh).password_reset_code = 1
      User.should_receive(:find_by_password_reset_code).and_return(user)
      get :edit, :id => 1
      response.should be_success
    end
  end

  describe "PUT 'update'" do
    before(:each) do
      @user = users(:josh)
    end
    
    it "should be successful" do
      User.should_receive(:find_by_password_reset_code).with('1').and_return(@user)
      @user.should_receive(:update_attributes).and_return(true)
      UserMailer.should_receive(:deliver_reset_password)
      put :update, :id => 1
      flash[:notice].should == "Your password has been updated, please login."
      response.should redirect_to(login_url)
    end
    
    it "should redirect when it can't find the reset code" do
      lambda {put :update, :id => 1}.should raise_error
      response.code == "404"
    end
    
    it "should re-render edit when it has trouble saving" do
      User.should_receive(:find_by_password_reset_code).with('1').and_return(@user)
      @user.should_receive(:update_attributes).and_return(false)
      put :update, :id => 1
      flash[:warning].should == "We were unable to update your password, please try a different one."
      response.should be_success
      response.should render_template("passwords/edit")
    end
    
  end
  
end
