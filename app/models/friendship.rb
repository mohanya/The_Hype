# == Schema Information
# Schema version: 20100413205506
#
# Table name: friendships
#
#  id         :integer(4)      not null, primary key
#  user_id    :integer(4)      
#  friend_id  :integer(4)      
#  created_at :datetime        
#  updated_at :datetime        
#

class Friendship < ActiveRecord::Base
  belongs_to :user
  belongs_to :friend, :class_name => "User", :foreign_key =>'friend_id'

  validates_presence_of :user
  validates_presence_of :friend
  after_create :create_notification
  after_create :send_email
    
  def create_notification
     Notice.delay.create(:about => 'Follow', :sender_id => user.id, :user_id  => friend.id)
  end

  def send_email
    #UserMailer.delay.deliver_follower_notice(self) if self.friend.profile.follower_notice
  end
end
