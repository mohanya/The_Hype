# == Schema Information
# Schema version: 20100413205506
#
# Table name: subscriptions
#
#  id                :integer(4)      not null, primary key
#  profile_id        :integer(4)      
#  subscribed_at     :datetime        
#  signup_ip_address :string(255)     
#  created_at        :datetime        
#  updated_at        :datetime        
#


class Subscription < ActiveRecord::Base
  belongs_to :profile
  
  validates_presence_of :signup_ip_address
  validates_presence_of :profile

  before_create :set_subscribed_at
  
  private
  
    def set_subscribed_at
      self.subscribed_at = Time.now
    end
end
