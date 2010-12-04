# == Schema Information
# Schema version: 20100413205506
#
# Table name: users
#
#  id                        :integer(4)      not null, primary key
#  login                     :string(255)     
#  email                     :string(255)     
#  crypted_password          :string(40)      
#  salt                      :string(40)      
#  created_at                :datetime        
#  updated_at                :datetime        
#  remember_token            :string(255)     
#  remember_token_expires_at :datetime        
#  activation_code           :string(40)      
#  activated_at              :datetime        
#  state                     :string(255)     default("passive")
#  deleted_at                :datetime        
#  admin                     :boolean(1)      
#  password_reset_code       :string(255)     
#  invites                   :integer(4)      default(3)
#  sent_activation           :boolean(1)      
#  time_zone                 :string(255)     
#  fb_user_id                :integer(8)      
#  email_hash                :string(255)     
#

require 'digest/sha1'
class User < ActiveRecord::Base
  liquid_methods :login, :activation_code, :password_reset_code

  cattr_reader :per_page
  @@per_page = 20

  # Virtual attribute for the unencrypted password
  attr_accessor :password, :current_password, :password_being_changed
  
  has_one :profile, :dependent => :destroy
  has_many :followers_fr, :class_name => 'Friendship', :foreign_key => 'friend_id', :dependent => :destroy
  has_many :followers, :through => :followers_fr, :source => 'user'

  has_many :friendships, :dependent => :destroy, :foreign_key => 'user_id'
  has_many :following, :through => :friendships, :source => 'friend'

  has_many :received_messages, :class_name => 'Message', :foreign_key => 'receiver_id', :dependent => :destroy
  has_many :sended_messages, :class_name => 'Message', :foreign_key => 'sender_id', :dependent => :destroy
  has_many :notices, :dependent => :destroy, :conditions => 'deleted_at is NULL'
  has_many :sender_notices, :dependent => :destroy, :class_name => 'Notice', :foreign_key => 'sender_id'

  named_scope :with_name_like, lambda { |name_query|
    name = "#{name_query}%"
     {:joins => "INNER JOIN profiles ON profiles.user_id = users.id", :conditions => ["UPPER(profiles.first_name) LIKE UPPER(?) or UPPER(profiles.last_name) LIKE UPPER(?) or UPPER(login) LIKE UPPER(?)", name, name, name]}
    }

  named_scope :find_by_full_name, lambda {|full_name|  {:joins => "INNER JOIN profiles ON profiles.user_id = users.id", :conditions => ["UPPER(profiles.first_name) LIKE UPPER(?) or UPPER(profiles.last_name) LIKE UPPER(?)", full_name.split(' ').first, full_name.split(' ').last]}}

  named_scope :followed_by, lambda { |user|
    user_id =  user.is_a?(User) ? user.id : user.to_i
    {:joins => "INNER JOIN friendships AS followed_by_friendships ON followed_by_friendships.friend_id = users.id", 
     :conditions => {:followed_by_friendships => {:user_id => user_id}}
    }
  }
  named_scope :limit_by, lambda { |limit| {:limit => limit.to_i}}
  after_update :delete_cache
  before_destroy :delete_cache
  after_create :register_user_to_fb
  def top
    UserTop.find_all_by_user_id(self.id)
  end

  def friends
    followers.followed_by(self)
  end

  def friend_ids
    friend_ids = self.following.map {|f| f.id}
  end

  # has_many :items
  

 
  
  validates_presence_of     :login, :email
  validates_presence_of     :password,                   :if => :password_required_or_being_changed?
  validates_presence_of     :password_confirmation,      :if => :password_required_or_being_changed?
  validates_length_of       :password, :within => 4..40, :if => :password_required_or_being_changed?
  validates_confirmation_of :password,                   :if => :password_required_or_being_changed?
  validates_length_of       :login,    :within => 3..40
  validates_length_of       :email,    :within => 3..100
  validates_uniqueness_of   :login, :email, :case_sensitive => false
  before_save :encrypt_password
  validate_on_create :has_invite
  validate :current_password_matches, :if => :password_being_changed
  
  #Auto admin the first user
  #before_create :make_first_admin
  #after_create :auto_activate_admin
  after_create :use_invite

  after_create :register_user_to_fb
  
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :password, :password_confirmation, :time_zone, :profile_attributes
  accepts_nested_attributes_for :profile

  named_scope :active, :conditions => {:state => :active}
  

  has_friendly_id :name, :use_slug => true

  acts_as_tagger
  
  acts_as_state_machine :initial => :pending
  state :passive
  state :pending, :enter => :make_activation_code
  state :active,  :enter => :do_activate
  state :suspended
  state :deleted, :enter => :do_delete

  event :register do
    transitions :from => :passive, :to => :pending, :guard => Proc.new {|u| !(u.crypted_password.blank? && u.password.blank?) }
  end
  
  event :activate do
    transitions :from => :pending, :to => :active 
  end
  
  event :suspend do
    transitions :from => [:passive, :pending, :active], :to => :suspended
  end
  
  event :delete do
    transitions :from => [:passive, :pending, :active, :suspended], :to => :deleted
  end

  event :unsuspend do
    transitions :from => :suspended, :to => :active,  :guard => Proc.new {|u| !u.activated_at.blank? }
    transitions :from => :suspended, :to => :pending, :guard => Proc.new {|u| !u.activation_code.blank? }
    transitions :from => :suspended, :to => :passive
  end

  unless RAILS_ENV == 'test'
    # Sunspot / WebSolr / Search stuff
    # this adds the User#search method which conflicts with Searchlogic!
    searchable do
      text :login, :email
      text :first_name do
        profile.first_name
      end
      text :last_name do
        profile.last_name
      end
      string :first_name do
        profile.first_name
      end
      string :last_name do
        profile.last_name
      end
      text :about_me do
        profile.about_me
      end
      text :city do
        profile.city
      end
      text :country do
        profile.country
      end
    end
  end

  def self.find_by_fb_user(fb_user)
    # find_by_email_hash throwing Facebooker::Session::SessionExpired
    # User.find_by_fb_user_id(fb_user.uid) || User.find_by_email_hash(fb_user.email_hashes)
    User.find_by_fb_user_id(fb_user.uid)
  end

  # Take the data returned from facebook and create a new user from it.
  # We don't get the email from Facebook and because a facebooker can only 
  # login through Connect we just generate a unique login name for them.
  # If you were using username to display to people you might want to get 
  # them to select one after registering through Facebook Connect

  #~ def self.populate_from_fb_connect(fb_user)
    #~ new_facebooker = User.new(:login => "#{fb_user.profile_url.split('/').last}")
    #~ new_facebooker.fb_user_id = fb_user.uid.to_i
    #~ new_facebooker.email = fb_user.email
    #~ new_facebooker
  #~ end
  
  def populate_from_fb_connect(fb_user)
    login=fb_user.profile_url.split('/').last
    fb_user_id=fb_user.uid.to_i
    email=fb_user.email
  end

  def self.get_other_info(fb_user)
     @data = {}
     @data[:first_name] = fb_user.first_name
     @data[:last_name] = fb_user.last_name
     @data[:birth_date] = fb_user.birthday_date
     @data[:is_male] = (fb_user.sex == 'male') ? 'Male' : 'Female'
     return @data
  end

  def self.create_from_fb_connect(fb_user)
    new_facebooker = User.new(:name => fb_user.name, :login => "facebooker_#{fb_user.uid}", :password => "", :email => "")
    new_facebooker.fb_user_id = fb_user.uid.to_i

    new_facebooker.save(false)
  end

  def set_favorite(item)
    fave = ItemFavorite.first_or_new(:item_id => item.id, :user_id => self.id)    
    fave.item_category_id = item.category_id
    if fave.favorite == true
      fave.favorite = false
    else
      fave.favorite = true
    end
    
    if fave.save
      return fave
    else
      return false
    end
  end

  #We are going to connect this user object with a facebook id. But only ever one account.
  def link_fb_connect(fb_user_id)
    unless fb_user_id.nil?
      #check for existing account
      existing_fb_user = User.find_by_fb_user_id(fb_user_id)
   
      #unlink the existing account
      unless existing_fb_user.nil?
        existing_fb_user.fb_user_id = nil
        existing_fb_user.save(false)
      end
   
      #link the new one
      self.fb_user_id = fb_user_id
      save(false)
    end
  end

  # The Facebook registers user method is going to send the users email hash and our account id to Facebook
  # We need this so Facebook can find friends on our local application even if they have not connect through connect
  # We then use the email hash in the database to later identify a user from Facebook with a local user
  def register_user_to_fb
    if self.facebook_user?
      users = {:email => email, :account_id => id}
      Facebooker::User.register([users])
      self.email_hash = Facebooker::User.hash_email(email)
      save(false)
    end
  end

  def facebook_user?
    return !fb_user_id.nil? && fb_user_id > 0
  end
  
  def last_hype_item
    if review = Review.find_by_user_id(self.id, :order => 'created_at desc', :select => 'item_id')
      Item.first(:id => review.item_id, :select => 'name, id')
    end
  end
  
  def reviews(limit = nil)
    options = {:user_id => self.id, :order => 'created_at DESC'}
    options.merge!({:limit => limit}) if limit
    Review.all(options)
  end

  def limited_reviews(limit)
    Review.all(:limit => limit,  :user_id => self.id, :order => 'created_at desc', :select => 'created_at, id, name, item_id')
  end

  def tips(limit = nil)
    options = {:conditions=>{:user_id => self.id}, :order => 'score desc'}
    options.merge!({:limit => limit}) if limit
    Tip.all(options)
  end
  
  def reviews_count
    Review.count({:user_id => self.id})
  end
  
  def comments
    Comment.all({:user_id => self.id})
  end

  def likes
    Like.all({:user_id => self.id})
  end

  def votes
    Vote.all({:user_id => self.id})
  end

  def activities
    Activity.all({:user_id => self.id})
  end

  def items
    Item.all(:conditions=>{:user_id => self.id})
  end
  
  def self.find_comment_notice_preference(users_ids)
    find(:all, :joins => :profile, :conditions => ["users.id IN (?)", users_ids], :select => "users.*, comment_notice")    
  end

  
  def twitt!(body)
    raise "Body can't be empty" if body.nil? or body.empty?
    self.profile.twitter_client.update(body)
  end

  def get_twitter_name
    if !self.profile.twitter_name || (self.profile.twitter_updated_at < 3.days.ago)
      begin
        screen_name =  Twitter.user(self.twitter_id).screen_name 
        self.profile.update_attributes(:twitter_name => screen_name, :twitter_updated_at => Time.now)
      rescue
      end
    end
    return self.profile.twitter_name
  end

  def unlink_twitter
    self.profile.twitter_token = nil
    self.profile.twitter_secret = nil
    self.profile.save
  end

  def calculate_peer_score
    profile.peer_review_score = reviews.to_a.sum(&:peer_approval) / reviews.size
    profile.save
  end

  def activated!
    update_attribute(:sent_activation, true)
  end

  def has_friend(user)
    friendships.find_by_friend_id(user.id, :select => 'id')
  end

  def has_invite
    return true unless User.invite_required?
    errors.add("beta_invite", "couldn't be found with the email you provided") if Invite.usable(self.email).empty?
  end
  
  def has_invites?
    invites > 0 || admin?
  end

  def self.invite_required?
    SiteSetting.find(:first).beta_invites? 
  end

  def count_comment_replies
    Comment.count(:user_id_of_parent => self.id, :deleted_from_inbox => false, :read => false)
  end

  def count_unread_messages
    received_messages.unread.count
  end

  def use_invite
    if User.invite_required?
      invite = Invite.usable(self.email).first
      invite.use!
    end
  end

  def self.invite_count
    User.sum(:invites)
  end
  
  def name
    (profile && !profile.fullname.blank?) ? profile.fullname : login
  end
  
  def make_first_admin
    self.admin = true if make_admin?
  end
  
  def make_admin?
    User.count == 0
  end
  
  def auto_activate_admin
    if (self.state == "pending" && self.admin?)
      self.activate!
    end
  end
  
  def promote!
    self.update_attribute(:admin, true)
  end
  
  def demote!
    self.update_attribute(:admin, false)
  end
  
  def email=(email)
    if profile
      profile.email = email
    else
      profile = Profile.find_or_create_by_email(email)
      self.profile = profile
    end
    
    self.profile.assigned_to_user = true # required to modify validation mechanism in profile
    super(email)
  end
  
  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    if login.include?("@")
      u = find_in_state :first, :active, :conditions => {:email => login} # need to get the salt
    else
      u = find_in_state :first, :active, :conditions => {:login => login} # need to get the salt
    end
    u && u.authenticated?(password) ? u : nil
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at 
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    remember_me_for 2.weeks
  end

  def remember_me_for(time)
    remember_me_until time.from_now.utc
  end

  def remember_me_until(time)
    self.remember_token_expires_at = time
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end

  def twitter?
    !self.profile.twitter_token.nil? && !self.profile.twitter_secret.nil? && !self.profile.twitter_id.nil?
  end

  def tweet(text)
    profile.twitter_client.update(text[0..139])  rescue true
  end

  def make_password_reset_code
    self.update_attribute(:password_reset_code, make_hash_code) if self.password_reset_code.blank?
  end
  
  def favorites(options = {})
    ItemFavorite.all({:user_id => self.id, :favorite => true, :select => 'item_id'}.merge(options)).collect(&:item)
  end

  def has_favorites?
    ItemFavorite.first(:user_id => self.id)
  end

  def item_favorites
    ItemFavorite.all(:user_id => self.id)
  end

  def paginated_favorites(category, find_more, options={})
    limit = options[:limit] || 5
    offset = options[:offset] || 0
    more = false
    options = {:user_id => self.id, :favorite => true, :select => 'item_id', :order => 'created_at DESC'}
    if category.children.empty?
       options = options.merge(:item_category_id => category.id)
    else
      category_ids = [category.id] + category.children.collect(&:id).to_a
      options = options.merge(:item_category_id => {'$in' => category_ids})
    end
    all = ItemFavorite.all(options.merge(:offset => offset, :limit => limit))
    unless all.empty?
      all =  Item.all(:id => {'$in' => all.collect(&:item_id)}, :select => 'id, name, score, category_id')
      if find_more
        more = ItemFavorite.first(options.merge(:offset => offset + limit))
      end
    end
    return all, more
  end

  def essentials
    @essentials ||= Essential.essential_categories.map do |category| 
      Essential.first_or_new(:user_id => self.id, :essential_category => category) 
    end
  end
  
  def essentials=(essentials_attributes)
    #essentials_by_category = self.essentials.group_by(&:essential_category)
    essentials_attributes.map do |essential_id, essential_attributes|
      essential = self.essentials.detect {|e| e.essential_category == essential_attributes[:essential_category]}
      if essential_attributes[:item_id].blank?
        essential.destroy
      else
        essential.item_id = essential_attributes[:item_id]
        essential.save!
      end
    end
  end
  
  def essentials_count
    Essential.count(:user_id => self.id)
  end
  
  def twitter_id
    profile.twitter_id
  end

  def delete_cache
    host = (RAILS_ENV == "development" ) ? "localhost:3000" : "test.thehypenetworks.com"
    self.expire_fragment("#{host}/users/#{self.slug.name}?key=#{self.id.to_s}_panel")
  end

  protected
    # before filter 
    def encrypt_password
      return if password.blank?
      self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
      self.password_reset_code = nil unless new_record?
      self.crypted_password = encrypt(password)
    end
      
    def password_required?
      required = (crypted_password.blank? || !password.blank?)
    end
    
    def make_activation_code
      self.deleted_at = nil
      self.activation_code = make_hash_code
    end
    
    def make_hash_code
      Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
    end
    
    def do_delete
      self.deleted_at = Time.now.utc
    end

    def do_activate
      self.activated_at = Time.now.utc
      self.deleted_at = self.activation_code = nil
    end
    
    def validate_current_password?
      !current_password.blank?
    end
    
    def password_required_or_being_changed?
      password_required? || password_being_changed
    end
    
    def current_password_matches
      errors.add(:current_password, "must be valid") unless authenticated?(current_password)
    end

    def self.delete_with_all(id)
       user = User.find(id)
       user.reviews.collect{|x| x.destroy}
       user.likes.collect{|x| x.destroy}
       user.votes.collect{|x| x.destroy}
       user.tips.collect{|x| x.destroy}
       user.comments.collect{|x| x.destroy}
       user.item_favorites.collect{|x| x.destroy}
       user.activities.collect{|x| x.destroy}
       Mailer.deliver_info_for_admin(user.email)
       user.destroy
    end
    
    def publish_to(target, options = {})
      @session.post('facebook.stream.publish', prepare_publish_to_options(target, options), false)
    end
    #added for changind login to username
    HUMANIZED_ATTRIBUTES = {
    :login => "Username"
    }

    def self.human_attribute_name(attr)
      HUMANIZED_ATTRIBUTES[attr.to_sym] || super
    end

     def self.message_body(name)
    str =  <<-START
  Hey  #{name} <br/><br/>
  Just wanted to officially welcome you to The Hype.  We appreciate your contribution at this <br/>
  early phase.  The Hype is built to give every consumer an online & mobile source of trusted<br/>
  and reliable consumer information.  A place to easily capture, gather, and exchange<br/>
  consumer experiences as they happen on any items with friends and family.  <br/>
   <br/>
  The Hype is founded on two core principles; authenticity and transparency.  In order to<br/>
  ensure the site and it's content is authentic we highly encourage each user to complete their<br/>
  profile and invite their friends and family to The Hype.  Having your friends and family, those <br/>
  trusted sources, using the service is the best way to ensure the people are transparent and <br/>
  the information is authentic.  Completing your profile also helps your friends find you easier<br/>
  as well as gives them more insight into what consumer tastes you might share. <br/>
  <br/>
  So, complete that profile, invite those trusted sources to the site, and start capturing your<br/>
  experiences!  If you need any assistance with the site go to our help section or tweet us at<br/>
  @thehype.  Also, please point out any issues or offer feedback by selecting the 'Feedback'<br/>
  tab seen on the side of your browser window.<br/>
  <br/>
  Thanks for your contributions, have fun and welcome to the consumer revolution...where you<br/>
  decide!<br/>
  <br/>
  BTW - If you have an iPhone check out our app in the iTunes store so you can capture and<br/>
  exchange your experiences with friends while your having them.<br/>
  <br/>
  The Hype Team

   
    START
    end
end
