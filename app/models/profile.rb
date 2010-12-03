# == Schema Information
# Schema version: 20100413205506
#
# Table name: profiles
#
#  id                  :integer(4)      not null, primary key
#  email               :string(255)     
#  first_name          :string(255)     
#  last_name           :string(255)     
#  referral_id         :integer(4)      
#  user_id             :integer(4)      
#  subscribed          :boolean(1)      
#  created_at          :datetime        
#  updated_at          :datetime        
#  avatar_file_name    :string(255)     
#  avatar_content_type :string(255)     
#  avatar_file_size    :integer(4)      
#  job                 :string(255)     
#  birth_date          :date            
#  income              :integer(4)      
#  married             :boolean(1)      
#  consumer_type       :string(255)     
#  trusted_brands      :string(255)     
#  computer            :string(255)     
#  automobile          :string(255)     
#  mobile_phone        :string(255)     
#  band                :string(255)     
#  book                :string(255)     
#  movie               :string(255)     
#  destination         :string(255)     
#  tos                 :boolean(1)      
#  peer_review_score   :float           
#  hyper_type          :string(255)     
#  follower_notice     :boolean(1)      default(TRUE)
#  comment_notice      :boolean(1)      default(TRUE)
#


class Profile < ActiveRecord::Base
  liquid_methods :email
  
  attr_writer :assigned_to_user
  
  belongs_to :user
  belongs_to :referral, :class_name => "Profile", :foreign_key => "referral_id"
  belongs_to :education_level
  belongs_to :consumer_type
  
  validates_uniqueness_of :email, :case_sensitive => false, :unless => :assigned_to_user?
  #validates_format_of :blog, :with => URI.regexp(['http']), :allow_blank=> true, :allow_nil => true
  validates_presence_of :email, :unless => :assigned_to_user?
  validate :gender_presence, :if => :assigned_to_user?
  validates_presence_of :birth_date, :if => :assigned_to_user?
  validates_presence_of :first_name, :if => :assigned_to_user?
  validates_presence_of :last_name, :if => :assigned_to_user?
  validates_length_of :email,    :within => 3..100, :unless => :assigned_to_user?
  validate :about_me_is_short_enough
  named_scope :referrers, :conditions => {:referral_id => nil}
   
  has_many :interests, :dependent => :destroy
  has_many :trusted_brands, :dependent => :destroy
  
  before_save :update_twitter_id
  
  has_attached_file :avatar, :styles => {:thumb => "16x16>", :small => "48x54#", :large => "100x100>", :xlarge => "160x180#"},
      :default_url => "default_:gender_:style_avatar.png",
      :default_style => :large,
      :storage => :s3,
      :bucket => "#{Rails.env}.thehype.com",
      :s3_credentials => "#{RAILS_ROOT}/config/amazon_s3.yml",
      :url => "/images/profiles/:id/:style/:basename.:extension",
      :path => ":id/:style/:basename.:extension"                  
  
  def self.hyper_types
    %w{Music Tech Movie}
  end
  
  def self.genders
    %w{Male Female}
  end

  
  def gender=(value)
    case value
    when 'Male'
      self.is_male = true
    when 'Female'
      self.is_male = false
    else
      self.is_male = nil 
    end
  end
  
  def gender
    if self.is_male.nil?
      ''
    else
      self.is_male? ? 'Male' : 'Female'
    end
  end
  
  def fullname
    return nil unless first_name && last_name
    "#{first_name} #{last_name}"
  end
  
  def add_referrals(friends_list, email_text)
    emails = Profile.parse_friends_email(friends_list)
    referrals = emails.collect do |email|
      Profile.find_or_create_by_email(:email => email, :referral => self)
    end
    Profile.send_referral_emails(self, referrals, email_text)
    referrals
  end
  
  def self.parse_friends_email(email_list = "")
    if email_list.include?("\r\n")
      emails = email_list.split(/\r\n/)
    else
      emails = email_list.split(/,/)
    end
    emails
  end
  
  def self.send_referral_emails(sender, referrals, text)
    referrals.each do |profile|
      ReferralMailer.delay.deliver_referral(profile, text)
    end
    ReferralMailer.delay.deliver_confirmation(sender)
    ReferralMailer.delay.deliver_admin_confirmation(sender, referrals)
  end
  
  def interest_list
    get_list_from_collection(interests)
  end
  
  def interest_list=(value)
    create_collection_from_list(Interest, value)
  end
  
  def trusted_brand_list
    get_list_from_collection(trusted_brands)
  end
  
  def trusted_brand_list=(value)
    create_collection_from_list(TrustedBrand, value)
  end

  def blog_link
     regex = /https?:\/\/(.*)/.match(blog)
     if regex==nil
        return "http://#{blog}"
     else
        return blog
     end
  end
  
  BASE_PERCENT = 25
  AVATAR_PERCENT = 5
  def signup_progress
    percent_left = 100 - (BASE_PERCENT + AVATAR_PERCENT)
    required_fields = %w[country city education_level job about_me trusted_brand_list interest_list]
    completed_fields = required_fields.reject { |attrib| self.send(attrib).blank? }
    required_fields_count = required_fields.length + ItemCategory.count(:conditions =>{:parent_id => nil}) + Essential.essential_categories.count
    completed_fields_count = completed_fields.length + self.user.top.count + self.user.essentials_count
    percent = BASE_PERCENT + (self.avatar? ? AVATAR_PERCENT : 0) + (completed_fields_count * percent_left / required_fields_count).ceil
  end
  
  def twitter_client
    raise "Twitter key(s) missing" if self.twitter_token.nil? || self.twitter_secret.nil?
      
    keys = load_twitter_keys()
    
    oauth = Twitter::OAuth.new(keys['token'], keys['secret'])
    oauth.authorize_from_access(self.twitter_token, self.twitter_secret)

    Twitter::Base.new(oauth)
  end

  def get_info_from_facebook(fb_user)
    if fb_user 
      if fb_user.current_location
        self.country = fb_user.current_location.country
        self.city = fb_user.current_location.city + ', ' + fb_user.current_location.state
      end
      if fb_user.pic_big_with_logo
         self.avatar = do_download_remote_image(fb_user.pic_big)
      end
    end
  end

  private
  
  def avatar_progress
    avatar? ? AVATAR_PERCENT : 0
  end
  
  def create_collection_from_list(record_class, list)
      new_items = []
      list.split(',').each_with_index do |name, pos|
        new_items << record_class.new(:name => name, :pos => pos + 1)
      end
      self.send("#{record_class.to_s.tableize}=", new_items)
  end
  
  def get_list_from_collection(collection)
    collection.map(&:name).join(', ')
  end
  
  def gender_presence
    #~ errors.add(:gender, "You must provide gender") if gender.blank?
    errors.add(:gender, "can't be blank") if gender.blank?
  end
  
  def about_me_is_short_enough
    errors.add(:about_me, "You can to use up to 600 characters to tell others something about yourself.") if about_me && about_me.length > 600
  end
  
  def assigned_to_user?
    @assigned_to_user || !user.nil?
  end
  
  def update_twitter_id
    if self.twitter_token.nil? || self.twitter_secret.nil?
      self.twitter_id = nil
    else
      if self.twitter_id.nil? || self.twitter_token_changed? ||  self.twitter_secret_changed? 
        self.twitter_id = self.twitter_client.verify_credentials.id
      end
    end
  end

  require 'open-uri'
  attr_reader :url
  def do_download_remote_image(uri)
    io = open(URI.parse(uri))
     def io.original_filename; base_uri.path.split('/').last; end
       io.original_filename.blank? ? nil : io
    rescue # catch url errors with validations instead of exceptions (Errno::ENOENT, OpenURI::HTTPError, etc...)
end



  def load_twitter_keys
    if RAILS_ENV=='production'
      return YAML::load(File.open("#{RAILS_ROOT}/config/external_apis.yml"))['twitter']['production']
      
    elsif RAILS_ENV=='development'
      return YAML::load(File.open("#{RAILS_ROOT}/config/external_apis.yml"))['twitter']['development']
    end
  end

  Paperclip.interpolates :gender do |attachment, style|
     (attachment.instance.is_male.nil? ||   attachment.instance.is_male?) ? 'male' : 'female'
  end
end
