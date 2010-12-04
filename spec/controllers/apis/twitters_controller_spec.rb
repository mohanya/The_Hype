require 'spec_helper'

describe Apis::TwittersController do

  fixtures(:users)
  fixtures(:profiles)

  before do
    login_as(:quentin)
    @user = users(:quentin)

    @oauth = mock(Object)
    Twitter::OAuth.stub!(:new).and_return(@oauth)
  end

  describe "GET/auth" do
    it "should get & store tokens in session and redirect to twitter.com " do
      @request_token = mock(Object, 
                            :token => "some_token", 
                            :secret => "some_secret",
                            :authorize_url => "http://twitter.com"
                           )

      @oauth.stub!('request_token').and_return(@request_token)

      get(:auth)

      controller.session['oauth_request_token_token'].should == "some_token"
      controller.session['oauth_request_token_secret'].should == "some_secret"
      response.should redirect_to('http://twitter.com')
    end

    it "should redirect to /friends/twitter/new with error message " do
      pending
      @oauth.stub!('request_token').and_raise(StandardError.new('error!'))
      get(:auth)

      flash[:notice].should == "error!"
      response.should redirect_to('/friends/twitter/new')
    end

    it "should redirect to Step 4 with error message " do
      @oauth.stub!('request_token').and_raise(StandardError.new('error!'))
      get(:auth, :from => "wizard")

      flash[:notice].should == "error!"
      response.should redirect_to(session[:twitter_callback])
    end
  end

  describe("GET/new")
    before() do
      profile = @user.profile
      profile.gender = 'Male'
      profile.birth_date = Time.now
      profile.save

      access_token = ['token_for_user', 'secret_for_user']
      @oauth.stub!('authorize_from_request').and_return(access_token)
    end

    it "should save twitter keys in user profile" do
      pending
      controller.session[:twitter_callback] = '/friends/twitter/new'
      get(:new)

      user = User.find(@user.id)
      user.profile.twitter_token.should == 'token_for_user'
      user.profile.twitter_secret.should == 'secret_for_user'
    end

    it "should clear session keys" do
      pending
      controller.session[:twitter_callback] = '/friends/twitter/new'
      controller.session['oauth_request_token_token'] = "some_token"
      controller.session['oauth_request_token_secret'] = "some_secret"
   
      get(:new)

      controller.session['oauth_request_token_token'].should be_nil
      controller.session['oauth_request_token_secret'].should be_nil
    end

    it "should redirect to /friends/twitter/new" do
      controller.session[:twitter_callback] = '/friends/twitter/new'
      get(:new)
      response.should redirect_to(session[:twitter_callback])
    end

    it "should redirect to /friends/twitter/new with error message" do
      controller.session[:twitter_callback] = '/friends/twitter/new'
      @user.profile.stub!(:save).and_return(false)
      get(:new)

      flash[:notice] = "Could not save user"
      response.should redirect_to(session[:twitter_callback])
    end

end
