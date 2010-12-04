# == Schema Information
# Schema version: 20100413205506
#
# Table name: peer_reviews
#
#  id             :integer(4)      not null, primary key
#  user_id        :integer(4)      
#  review_id      :integer(4)      
#  helpful_review :boolean(1)      
#  created_at     :datetime        
#  updated_at     :datetime        
#

class PeerReview < ActiveRecord::Base
  cattr_reader :helpful, :unhelpful

  belongs_to :user
  belongs_to :review

  validates_presence_of :user
  validates_presence_of :review

  validates_uniqueness_of :review_id, :scope => :user_id

  after_create :calculate_peer_score

  @@helpful = 'up'
  @@unhelpful = 'down'

  def calculate_peer_score
    #user.delay.calculate_peer_score
    user.calculate_peer_score
  end
end
