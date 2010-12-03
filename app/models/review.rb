class Review 
  include MongoMapper::Document
  
  # iPhone API
  include CustomJsonSerializer
  include ApplicationHelper
  include IphoneApiMethods
  
  belongs_to :item, :foreign_key => :item_id
  many :activities, :polymorphic => true, :foreign_key => :source_id, :dependent => :destroy
  many :review_comments, :class_name => "ReviewComment", :dependent => :destroy
  many :labels, :dependent => :destroy, :class_name => 'Label'
  
  # key :_id, String
  key :item_id, String
  key :user_id, Integer
  key :criteria_1, Float, :default => 3
  key :criteria_2, Float, :default => 3
  key :criteria_3, Float, :default => 3
  key :score, Float, :default => 0
  key :first_word_list, String

  
  key :description, String
  key :recommended, Boolean
  key :shared, Boolean

  key :item_category_id
  key :_type, String
  timestamps!
  
  # Array of user ids of people who think a review is helpful or not
  # The attr_writers
  attr_accessor :helpful_user_id
  attr_accessor :unhelpful_user_id
  attr_accessor :con_list

  key :helpful_user_ids, Array
  key :unhelpful_user_ids, Array
  
  # iPhone API
  key :integer_id, Integer
  
  validates_presence_of :user_id
  validates_uniqueness_of   :item_id, :scope => :user_id, :message => 'You have already hyped this item!'
  
  before_save :unique_helpfulness
  before_create :add_integer_id
  after_create lambda { |review| Activity.delay.record(review.id, 'Review') }
  after_create :update_user_cache
  after_create :update_item_attributes
  after_destroy { |review| review.item.calculate_all_scores }


#  has_many :peer_reviews
#  has_many :helpful_approvals, :class_name => 'PeerReview', :conditions => {:helpful_review => true}

#  acts_as_taggable_on :cons, :pros, :first_words
  
#  named_scope :with_comments, :conditions => ["comments IS NOT NULL AND comments != \"\""]
#  named_scope :worth_hype, :conditions => {:recommended => true}
  
  
  def pros
    Label.all(:review_id => self.id, :type => 'pro')
  end
  
  def cons
    Label.all(:review_id => self.id, :type => 'con')
  end
  
  def user
    User.find(self.user_id)
  end
  
  def self.scores
    1..5
  end
  
  def peer_approval
    total = self.helpful_user_ids.size + self.unhelpful_user_ids.size
    return 0 if total == 0
    self.helpful_user_ids.size.to_f / total
  end
  
  def overall_score
    (self.criteria_1 + self.criteria_2 + self.criteria_3) / 3
  end
  
  # Before save: Ensure that only 1 user id is stored in the helpful and unhelpful arrays
  def unique_helpfulness
      if helpful_user_id
        self.unhelpful_user_ids.delete(helpful_user_id) if self.unhelpful_user_ids
        (self.helpful_user_ids << helpful_user_id).uniq
      elsif unhelpful_user_id
        self.helpful_user_ids.delete(unhelpful_user_id) if self.helpful_user_ids
        (self.unhelpful_user_ids << unhelpful_user_id).uniq      
      end
  end

  def get_tweeted
    text = "I just Hyped #{item.name[0..12]} and gave it a #{score.round(1)}. To see my consumer wisdom on this item & to share your own go to http://thehype.com/items/#{item.id}."
    user.profile.twitter_client.update(text[0..139]) rescue true
  end

  def update_item_attributes
    self.update_attributes(:score => self.overall_score)
    self.item.calculate_all_scores 
  end
  
  def update_user_cache
     self.user.delay.delete_cache
  end
  
  ###########################
  # 
  # iPhone API
  #
  ###########################

  def review
    self.description
  end
  
  def quality
    self.criteria_1
  end
  
  def value
    self.criteria_2
  end
  
  def utility
    self.criteria_3
  end
  
  def first_words
    self.first_word_list
  end
  
  def metric_ratings
    tab = []
    tags = all_criteria(self.item(:select => 'integer_id').id)
    tab[0] = {:metric_tag => tags[0].downcase, :rating => self.criteria_1}
    tab[1] = {:metric_tag => tags[1].downcase, :rating => self.criteria_2}
    tab[2] = {:metric_tag => tags[2].downcase, :rating => self.criteria_3}
    return tab
  end
  
  def user_details
    user = self.user
    profile = user.profile
    thumb_path = self.user_thumbnail_url
    hash = {
      :id => user.id,
      :username => user.name,
      :created_at =>  user.created_at,
      :updated_at => user.updated_at,
      :first_name => profile.first_name,
      :last_name => profile.last_name,
      :thumbnail_url =>thumb_path,
      :hypes_count => user.reviews_count,
      :followees_count => user.following.size,
      :followers_count => user.followers.size  
    }
    return hash
  end

  def pros_details
    tab = []    
    i = 0
    self.pros.each do |l|
      tab[i] = {
        :id => i, # is this really needed?
        :pro_id => i, # is this really needed?
        :text => l.tag,
        :created_at => self.created_at,
        :updated_at => self.created_at,
        :hype_id => self.integer_id,
        :item_id => Item.first(:id => l.item_id, :select => 'integer_id').integer_id,
        :count => 1 # is this really needed?
      }
      i += 1
    end
    return tab
  end
  
  def cons_details
    tab = []
    i = 0
    self.cons.each do |l|
      tab[i] = {
        :id => i, # is this really needed?
        :con_id => i, # is this really needed?
        :text => l.tag,
        :created_at => self.created_at,
        :updated_at => self.created_at,
        :hype_id => self.integer_id,
        :item_id => Item.first(:id => l.item_id, :select => 'integer_id').integer_id,
        :count => 1 # is this really needed?
      }
      i += 1
    end
    return tab
  end

  ###########################
  # 
  # end of iPhone API
  #
  ###########################

end
