class Message < ActiveRecord::Base
  belongs_to :sender, :class_name => "User"
  belongs_to :receiver, :class_name => "User"
  
  validates_presence_of :sender_id
  validates_presence_of :receiver_id, :message => 'Please include at recipient for this message.'

  named_scope :unread, :conditions => {:read => false}
  named_scope :newest, :order => 'created_at DESC'
  after_create :create_notification
  
  def validate
     errors.add(:subject, "Please write a message or include a subject before sending.") if (subject.blank? and body.blank?)
  end

  def create_notification
    about_field = case subject
      when "Follow request"
        "Request"
      when "Follow request accepted"
        "Request accepted"
      when "Follow request rejected"
        "Request rejected"
      else
        "Message"
      end
     Notice.delay.create(:about => about_field, :sender_id => sender.id, :user_id  => receiver.id)
  end

  def subject_reply
    if self.subject.downcase =~ /^\s*re:/
      self.subject
    else
      "Re: #{self.subject}"
    end
  end

  def other_user(user)
    if sender == user
      return receiver
    else
      return sender
    end
  end

  def newer_message
    Message.newest.find(:last, :conditions => ["created_at > ? and receiver_id = ? ", self.created_at, self.receiver_id])
  end
  
  def older_message
    Message.newest.find(:first, :conditions => ["created_at < ? and receiver_id = ?", self.created_at, self.receiver_id])
  end

  def self.new_reply(message)
    Message.new do |reply|
      reply.receiver = message.sender
      reply.subject = message.subject_reply
    end
  end
end

