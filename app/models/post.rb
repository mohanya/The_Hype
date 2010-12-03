# == Schema Information
# Schema version: 20100413205506
#
# Table name: posts
#
#  id             :integer(4)      not null, primary key
#  title          :string(255)     not null
#  permalink      :string(255)     
#  posted_at      :datetime        
#  body           :text            
#  author_id      :integer(4)      
#  comments_count :integer(4)      
#  state          :string(255)     default("draft")
#  page_title     :string(255)     
#  description    :string(155)     
#  keywords       :string(255)     
#  created_at     :datetime        
#  updated_at     :datetime        
#


class Post < ActiveRecord::Base
  belongs_to :author, :class_name => "User", :foreign_key => "author_id"
  
  validates_presence_of :title, :body, :author_id
  
  before_validation_on_create :mark_as_draft
  
  has_friendly_id :title, :use_slug => true
  named_scope :published, lambda { {:conditions => ["state = 'published' AND posted_at <= ?", Time.zone.now], :order => "posted_at DESC"} }
  
  def publish!
    publish_attributes = {}
    publish_attributes[:state] = "published"
    publish_attributes[:posted_at] = Time.now if posted_at.blank?
    self.update_attributes(publish_attributes)
  end
  
  def state=(choice)
    self.posted_at = Time.now if (choice == "published" && posted_at.blank?)
    super(choice)
  end
  
  protected
  
  def mark_as_draft
    self.state = "draft" if state.blank?
  end
  
end
