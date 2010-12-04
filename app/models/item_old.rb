# == Schema Information
# Schema version: 20090715085613
#
# Table name: items
#
#  id             :integer(4)      not null, primary key
#  source_id      :string(255)     
#  name           :string(255)     
#  created_at     :datetime        
#  updated_at     :datetime        
#  image_url      :string(255)     
#  image_height   :integer(4)      
#  image_width    :integer(4)      
#  comments_count :integer(4)      
#  score          :float           
#  last_hyped_at  :datetime        
#  criteria_1     :float           
#  criteria_2     :float           
#  criteria_3     :float           
#

class ItemOld < ActiveRecord::Base
  cattr_reader :sorts, :sort_by_score

  validates_presence_of :name, :on => :create, :message => "can't be blank"
  validates_presence_of :source_id, :on => :create, :message => "can't be blank"
  has_many :reviews
  has_many :comments
  has_many :item_details
  has_many :tags, :through => :reviews, :source => :taggings, :include => :tag, :conditions => "taggings.context = 'tags'"
  has_many :pros, :through => :reviews, :source => :taggings, :include => :tag, :conditions => "taggings.context = 'pros'"
  has_many :cons, :through => :reviews, :source => :taggings, :include => :tag, :conditions => "taggings.context = 'cons'"
  has_many :first_words, :through => :reviews, :source => :taggings, :include => :tag, :conditions => "taggings.context = 'first_words'"
  belongs_to :user

  @@sort_by_score = 'top_hype'
  @@sorts = { @@sort_by_score => 'score desc' }
  
  def image
    image_url || "/images/app/product_image_160.jpg"
  end
  
  def calculate_score
    self.criteria_1 = reviews.average(:criteria_1).to_f
    self.criteria_2 = reviews.average(:criteria_2).to_f
    self.criteria_3 = reviews.average(:criteria_3).to_f
    self.score = ((criteria_1 + criteria_2 + criteria_3)/3).to_f
    self.save
  end
  
  def calculate_hype_worth
    self.hype_worth = (( reviews.worth_hype.count.to_f / reviews.count.to_f ) * 100.to_f).to_i
    self.save
  end
  
  def tag_list
    joined_tags(tags)
  end
  
  def pro_list
    joined_tags(pros)
  end
  
  def con_list
    joined_tags(cons)
  end
  
  def first_word_list
    joined_tags(first_words)
  end
  
  def joined_tags(tags)
    tags.collect {|tagging| tagging.tag.name }.join(", ")
  end
  
end