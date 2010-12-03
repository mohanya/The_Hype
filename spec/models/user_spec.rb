require File.dirname(__FILE__) + '/../spec_helper'

# Be sure to include AuthenticatedTestHelper in spec/spec_helper.rb instead.
# Then, you can remove it from this and the functional test.
include AuthenticatedTestHelper

describe User do
  #fixtures :users
  
  before(:each) do
    @site = site_settings(:site)
    @josh = Factory(:user, :admin => true)
    @quentin = Factory(:user, :password => 'test', :password_confirmation => 'test')
    @josh.activate!
    @quentin.activate!
    @josh.should_not be_new_record
    @quentin.should_not be_new_record
  end
  
  describe 'being created' do
    before do
      @user = nil
      @creating_user = lambda do
        @user = Factory.build(:user)
        # User.new({ 
        #           :login => 'quire', 
        #           :email => 'quire@example.com', 
        #           :password => 'quire', 
        #           :password_confirmation => 'quire'
        #         })
        @user.register! if @user.valid?
        violated "#{@user.errors.full_messages.to_sentence}" if @user.new_record?
      end
    end
    
    it 'increments User#count' do
      @creating_user.should change(User, :count).by(1)
    end

    it 'initializes #activation_code' do
      @creating_user.call
      @user.reload.activation_code.should_not be_nil
    end

    it 'starts in pending state' do
      @creating_user.call
      @user.should be_pending
    end
  end

  it 'requires login' do
    lambda do
      u = Factory.build(:user, :login => nil)
      u.should_not be_valid
      u.should have(2).error_on(:login)
    end.should_not change(User, :count)
  end

  it 'requires password' do
    lambda do
      u = Factory.build(:user, :password => nil)
      u.should_not be_valid
      u.should have(3).error_on(:password)
    end.should_not change(User, :count)
  end

  it 'requires password confirmation' do
    lambda do
      u = Factory.build(:user, :password_confirmation => nil)
      u.should_not be_valid
      u.should have(1).error_on(:password_confirmation)
    end.should_not change(User, :count)
  end
  
  it 'resets password' do
    lambda {
      @quentin.password_being_changed = true
      @quentin.current_password = 'test'
      @quentin.update_attributes(:password => 'new password', :password_confirmation => 'new password')
    }.should change(@quentin, :crypted_password)
    User.authenticate(@quentin.login, 'new password').should == @quentin
  end

  it 'does not rehash password' do
    @quentin.update_attributes(:login => 'quentin2')
    User.authenticate('quentin2', 'test').should == @quentin
  end

  it 'authenticates user' do
    User.authenticate(@quentin.login, 'test').should == @quentin
  end

  it 'sets remember token' do
    @quentin.remember_me
    @quentin.remember_token.should_not be_nil
    @quentin.remember_token_expires_at.should_not be_nil
  end

  it 'unsets remember token' do
    @quentin.remember_me
    @quentin.remember_token.should_not be_nil
    @quentin.forget_me
    @quentin.remember_token.should be_nil
  end

  it 'remembers me for one week' do
    before = 1.week.from_now.utc
    @quentin.remember_me_for 1.week
    after = 1.week.from_now.utc
    @quentin.remember_token.should_not be_nil
    @quentin.remember_token_expires_at.should_not be_nil
    @quentin.remember_token_expires_at.between?(before, after).should be_true
  end

  it 'remembers me until one week' do
    time = 1.week.from_now.utc
    @quentin.remember_me_until time
    @quentin.remember_token.should_not be_nil
    @quentin.remember_token_expires_at.should_not be_nil
    @quentin.remember_token_expires_at.should == time
  end

  it 'remembers me default two weeks' do
    before = 2.weeks.from_now.utc
    @quentin.remember_me
    after = 2.weeks.from_now.utc
    @quentin.remember_token.should_not be_nil
    @quentin.remember_token_expires_at.should_not be_nil
    @quentin.remember_token_expires_at.between?(before, after).should be_true
  end

  it 'registers passive user' do
    user = Factory.build(:user, :password => nil, :password_confirmation => nil)
    user.should be_passive
    user.update_attributes(:password => 'new password', :password_confirmation => 'new password')
    user.register!
    user.should be_pending
  end

  it 'suspends user' do
    @quentin.suspend!
    @quentin.should be_suspended
  end

  it 'does not authenticate suspended user' do
    @quentin.suspend!
    User.authenticate(@quentin.login, 'test').should_not == @quentin
  end

  it 'deletes user' do
    @quentin.deleted_at.should be_nil
    @quentin.delete!
    @quentin.deleted_at.should_not be_nil
    @quentin.should be_deleted
  end
  
  it 'promotes a user to admin' do
    @quentin.should_not be_admin
    @quentin.promote!
    @quentin.should be_admin
  end
  
  it 'demotes a user from admin' do
    @josh.should be_admin
    @josh.demote!
    @josh.should_not be_admin
  end
  
  it 'makes a password reset code' do
    pending
    @josh.make_password_reset_code.should == true
    @josh.password_reset_code.should_not be_nil
  end
  
  it 'removes a password reset code after password reset' do
    pending
    @josh.make_password_reset_code
    @josh.password_reset_code.should_not be_nil
    @josh.update_attributes(:password => 'new password', :password_confirmation => 'new password')
    @josh.password_reset_code.should be_nil
  end

  describe "being unsuspended" do
    fixtures :users

    before do
      @user = @quentin
      @user.suspend!
    end
    
    it 'reverts to active state' do
      @user.unsuspend!
      @user.should be_active
    end
    
    it 'reverts to passive state if activation_code and activated_at are nil' do
      User.update_all :activation_code => nil, :activated_at => nil
      @user.reload.unsuspend!
      @user.should be_passive
    end
    
    it 'reverts to pending state if activation_code is set and activated_at is nil' do
      User.update_all :activation_code => 'foo-bar', :activated_at => nil
      @user.reload.unsuspend!
      @user.should be_pending
    end
  end

  describe 'checking notice preferences' do
    fixtures :users
    fixtures :profiles
    
    it 'pulls the collection with comment_notice joined from profile' do
      user = User.find_comment_notice_preference([1])  
      user.first.comment_notice.should == '1'
      users = User.find_comment_notice_preference([1, 2, 3])
      users[0].comment_notice.should == '1'      
      users[1].comment_notice.should == '0'
      users[2].comment_notice.should == '0'
    end
    
  end
  
  describe 'making an admin' do
    before do
      User.delete_all
      @user = create_user
      @user2 = create_user(:login => "quentin")
    end
    
    it "should not make the first user an admin" do
      @user.save
      @user.should_not be_admin
      @user.should_not be_active
    end
    
    it "should leave other users pending and non-admin" do
      @user2.save
      @user2.should_not be_admin
      @user2.should_not be_active
    end
    
  end
  
  describe "should require an invite if beta invite is turned on" do
    it "and validates a user that has an invite" do
      @site.beta_invites = true
      @site.save
      invite = Invite.new(:email => 'quire@example.com', :inviter_id => @quentin.id, :used => false)
      invite.stub!(:send!)
      invite.save
      lambda{create_user(:email => 'quire@example.com')}.should change(User, :count)
    end
    
    it "and doesn't validate a user with no invite" do
      @site.beta_invites = true
      @site.save
      Invite.delete_all
      lambda do
        user = Factory.build(:user)
        user.should_not be_valid
        user.should have(1).error_on(:beta_invite)
      end.should_not change(User, :count)
    end
    
    it "and returns true if beta invite is turned off" do
      @site.beta_invites = false
      @site.save
      user = create_user
      user.errors.on(:beta_invite).should be_nil
    end
    
    it "and uses up the invite after creating the user account" do
      @site.beta_invites = true
      @site.save
      invite = Invite.new(:email => 'quire@example.com', :inviter_id => @quentin.id, :used => false)
      invite.stub!(:send!)
      invite.save
      user = create_user(:email => invite.email)
      invite.reload
      invite.should be_used
    end
    
    it "and should return an overall invite count" do
      @site.beta_invites = true
      @site.save
      User.invite_count.should_not be_nil
    end
    
  end

  it "should create a profile for a new user" do
    lambda do
      @user = create_user
    end.should change(Profile, :count)
    @user.reload.profile.should_not be_blank
  end
  
  it "should use a profile that exists if the email addresses match and it is unused" do
    pending
    profile = Profile.create(:email => "Joe@profile_test.com")
    user = create_user(:email => "Joe@profile_test.com")
    user.reload.profile.should == profile
    user2 = Factory.build(:user, :email => "Joe@profile_test.com")
    user2.should have(1).error_on(:email)
  end
  
  it "should return the fullname when calling name and the profile is setup" do
    user = create_user
    user.profile.first_name = "Joe"
    user.profile.last_name = "Blow"
    user.name.should == "Joe Blow"
  end
  
  describe "with observers on" do
    
    it "should send a signup notifcation" do
      UserMailer.should_receive(:delay)
      User.with_observers(:user_observer) do
        create_user
      end
    end
    
    it "should send one activation notice" do
      user = create_user
      UserMailer.should_receive(:delay).with(:deliver_activation, user)
      User.with_observers(:user_observer) do
        lambda do 
          user.activate!
        end.should change(user, :sent_activation)
      end
    end
  end

  describe "friendships" do
    it "should know if a user is your friend" do
      user = create_user
      friend = create_user

      friendship = Factory(:friendship, :user => user, :friend => friend)

      user.has_friend(friend).should == true
      friend.has_friend(user).should == false
    end
  end

  it "should calculate peer review score" do
    pending
    user = create_user

    r1 = Review.make(:user_id => user.id)
    r1.helpful_user_ids = [2]
    r1.unhelpful_user_ids = [3]
    r1.save
    
    r2 = Review.make(:user_id => user.id)
    r2.helpful_user_ids = [4]
    r2.unhelpful_user_ids = [5]
    r2.save

    user.calculate_peer_score
    user.profile.peer_review_score.should == 0.5    
  end
  
  it "should list favorites" do
    user = User.first
    i1 = Item.make(:name => "fave1")
    i2 = Item.make(:name => "fave2")
    
    user.set_favorite(i1.id)
    user.set_favorite(i2.id)
    
    user.reload
    
    user.favorites.map {|f| f.name}.should include(i1.name)
    user.favorites.map {|f| f.name}.should include(i2.name)
  end
  
  it "should accept nested profile attributes" do
    profile = Factory(:profile, :job => 'software developer')
    profile_attributes = Factory.attributes_for(:profile)
    profile_attributes['job'] = "different job"
    user = create_user(:profile => profile)
    user.profile_attributes = profile_attributes
    user.save!.should == true
    user.reload
    #user.profile.reload    
    user.profile.job.should == "different job"
  end
  
 
  


protected
  def create_user(options = {})
    record = Factory(:user, options)
    record.register! if record.valid?
    record
  end
end
