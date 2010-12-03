class CommentNotificationsJob < Struct.new(:message)
  def perform  
    UserMailer.deliver_email_notice(message.receiver, message) if message.receiver.profile.email_notice    
  end
end