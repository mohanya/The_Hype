# == Schema Information
# Schema version: 20100413205506
#
# Table name: invites
#
#  id         :integer(4)      not null, primary key
#  email      :string(255)     
#  user_id    :integer(4)      
#  inviter_id :integer(4)      
#  used       :boolean(1)      
#  created_at :datetime        
#  updated_at :datetime        
#  approved   :boolean(1)      
#  sent_at    :datetime        
#


class Invite < ActiveRecord::Base
  liquid_methods :id
  
  belongs_to :inviter, :class_name => "User", :foreign_key => "inviter_id"
  belongs_to :user, :class_name => "User", :foreign_key => "user_id"
  
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :on => :create, :message => 'Sorry, email should look like email.'

  validate :ensure_inviter_has_invites, :if => Proc.new {|invite| !invite.inviter_id.nil?}
  validate :ensure_new_user, :on => 'create'
  
  before_create :remove_inviter_invite
  
  attr_accessible :email, :inviter_id
  
  named_scope :usable, lambda {|email| {:conditions => ["email = ? AND used = ? AND approved = ?", email, false, true]} }
  named_scope :unused, :conditions => ["used = ?", false]
  named_scope :used, :conditions => ["used = ?", true]
  named_scope :unapproved, :conditions => ["approved = ? OR approved IS NULL", false]
  
  def ensure_new_user
    if (old_invite and (!old_user or !old_user.active?))
      errors.add(:email, "We have already sent an invitation to that email")
      errors.add(:resend, 'Resend')
    elsif (old_user and  old_user.active?)
      errors.add(:email, "There is already an account with that email")
      errors.add(:explain_email, "An account already exists for that email address. Please select the 'X' and then login to the site. <br/><br/> Thank you.")
    end
  end
  
  def ensure_inviter_has_invites
    errors.add(:email, "Inviter is out of invites") unless inviter && inviter.has_invites?
  end

  def old_user
    User.find_by_email(email)
  end

  def old_invite
    Invite.find_by_email(email)
  end
  
  def new_user?
    User.find_by_email(email).nil?
  end
  
  def use!
    self.update_attribute(:used, true)
  end
  
  def add_inviter(user)
    self.inviter = user
  end
  
  def approve!
    self.update_attribute(:approved, true)
  end

  def unapproved?
    !approved?
  end
  
  def remove_inviter_invite
    if inviter
      inviter.invites -= 1
      inviter.save
    end
  end
  
  def send!
    if approved? && unsent?
      InviteMailer.delay.deliver_invite_notification(self)
    end
  end
  
  def unsent?
    sent_at.nil? || sent_at < Time.now
  end
  
  def sent?
    !(sent_at.nil? || sent_at > Time.now)
  end
  
end
