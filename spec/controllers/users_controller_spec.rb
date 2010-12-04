require File.dirname(__FILE__) + '/../spec_helper'

# Be sure to include AuthenticatedTestHelper in spec/spec_helper.rb instead
# Then, you can remove it from this and the units test.


describe UsersController do
  fixtures :users
  
  before(:all) do
    User.default_url_options[:host] = 'test.host'
  end
  after(:all) do
    User.default_url_options[:host] = nil
  end

  it "should have users index" do
    get :index, :per_page => 2
    response.should be_success
    assigns(:users).should_not be_nil
    assigns(:users).size.should == 2
  end

  it "support searching" do
    User.should_receive(:search).with('abc')
    get :search, :query => 'abc'
    response.should be_success
  end

  # it 'allows signup' do
  #   lambda do
  #     User.make(:login => 'user123')
  #     response.should be_redirect
  #     response.should redirect_to(edit_user_url(User.find_by_login('user123')))
  #   end.should change(User, :count).by(1)
  # end

  it "allows a new user to pull up the signup page" do
    get :new
    response.should be_success
  end
  
  it 'signs up user in pending state' do
    create_user
    assigns(:user).should be_pending
  end
  
  it 'signs up user with activation code' do
    create_user
    assigns(:user).activation_code.should_not be_nil
  end

  it 'requires login on signup' do
    lambda do
      create_user(:login => nil)
      assigns[:user].errors.on(:login).should_not be_nil
      response.should be_success
    end.should_not change(User, :count)
  end
  
  it 'requires password on signup' do
    lambda do
      create_user(:password => nil)
      assigns[:user].errors.on(:password).should_not be_nil
      response.should be_success
    end.should_not change(User, :count)
  end
  
  it 'requires password confirmation on signup' do
    lambda do
      create_user(:password_confirmation => nil)
      assigns[:user].errors.on(:password_confirmation).should_not be_nil
      response.should be_success
    end.should_not change(User, :count)
  end

  it 'requires email on signup' do
    lambda do
      create_user(:email => nil)
      assigns[:user].errors.on(:email).should_not be_nil
      response.should be_success
    end.should_not change(User, :count)
  end

  it 'activates user' do
    User.authenticate('aaron', 'test').should be_nil
    get :activate, :activation_code => users(:aaron).activation_code
    response.should redirect_to('/')
    flash[:notice].should_not be_nil
    User.authenticate('aaron', 'test').should == users(:aaron)
  end
  
  it 'does not activate user without key' do
    get :activate
    flash[:notice].should be_nil
  end
  
  it 'does not activate user with blank key' do
    get :activate, :activation_code => ''
    flash[:notice].should be_nil
  end
  
  it 'GET show fails without a login' do
    get :show, :id => users(:quentin).to_param
    response.should be_success
  end
  
  it 'requires login for show page' do
    login_as(:quentin)
    get :show, :id => users(:quentin).to_param
    response.should be_success
  end
  
  it "requires login for edit page" do
    get :edit, :id => users(:quentin).to_param
    response.should_not be_success
    login_as(:quentin)
    get :edit, :id => users(:quentin).to_param
    response.should be_success
  end
  
  describe "updates a user account" do
    before do
      login_as(:quentin)
      @user = users(:quentin)
      User.stub!(:find).and_return(@user)
    end


    it "and succeeds" do
      @user.should_receive(:valid?).and_return(true)
      put :update, :id => @user.to_param, :user => { :email => 'new_quentin@example.com' }
      @user.reload
      @user.email.should == 'new_quentin@example.com'
      response.should redirect_to(user_url(@user))
    end  

    it "and fails" do
      @user.should_receive(:valid?).and_return(false)
      put :update, :id => @user.to_param, :user => { :login => "xxxxx"}
      response.should render_template("users/edit")
    end
    
    it "should ignore password change on update" do
      profile = Factory(:profile) 
      @user.should_receive(:valid?).and_return(true)
      @user.should_receive(:profile).at_least(:once).and_return(profile)
      lambda {
        put :update, :id => @user.to_param, :user => { :password => 'new_secret', :password_confirmation => 'new_secret'}
        @user.reload
      }.should_not change(@user, :crypted_password)
      response.should redirect_to(user_url(@user))
    end  
    
  end
  
  it 'requires you be the owner to see the show page' do
    login_as(:quentin)
    lambda {get :show, :id => users(:aaron)}.should raise_error
  end
  
  describe "with invites" do
    before(:each) do
      login_as(:quentin)
      user = users(:quentin)
      @invite = mock_model(Invite)
      Invite.should_receive(:new).and_return(@invite)
      @invite.should_receive(:add_inviter).with(user)
    end

    it "creates an invite" do
      @invite.should_receive(:save).and_return(true)
      post :invite, :id => 1, :invite => {:email => "tom@test.com"}
      flash[:notice].should_not be_nil
      response.should redirect_to(user_path(1))
    end

    it "doesn't create a duplicate invite" do
      @invite.should_receive(:save).and_return(false)
      post :invite, :id => 1, :invite => {:email => "tom@test.com"}
      flash[:warning].should_not be_nil
      response.should redirect_to(user_path(1))
    end

  end
  
  describe 'follows/unfollows a user' do
    before(:each) do
      login_as(:quentin)
    end    
    
    it 'creates friendship and sends notification' do
      post :follow, :id => 2, :follow => 'true'
      Friendship.last.user.id.should == users(:quentin).id
      response.should have_text('Friend Added')
      #AM test if UserMailer was sent
    end
  end
  
  def create_user(options = {})
    user_attributes = { :login => 'quire', :email => 'quire@example.com',
      :password => 'quire', :password_confirmation => 'quire', :profile_attributes => {:first_name => "Josh", :last_name => "doe", :gender => 'Male', :birth_date => 25.years.ago}}.merge(options)
    post :create, :user => user_attributes
  end
end