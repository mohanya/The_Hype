class UserMailer < Mailer

  def signup_notification(user)
    setup_user_notification_email('signup', user)
  end
  
  def activation(user)
    setup_user_notification_email('activation', user)
  end
  
  def forgot_password(user)
    setup_user_notification_email('forgot_password', user)
  end
  
  def reset_password(user)
    setup_user_notification_email('reset_password', user)
  end
  
  def follower_notice(friendship)
   setup_template('follower_notice', friendship.friend.email) do |options|
     options['follower'] = friendship.user
   end     
  end
  
  def email_notice(receiver, sender)
   setup_template('email_notice', receiver.email) do |options|
     options['sender'] = sender
   end     
  end
  
  def comment_notice(comment, recipient)
   setup_template('comment_notice', recipient.email) do |options|
     options['commentator'] = comment.user
     options['item_name'] = comment.item.name 
   end     
  end
  
  def comment_notice_to_item_owner(comment, item_owner)
   setup_template('comment_notice_to_item_owner', item_owner.email) do |options|
     options['commentator'] = comment.user
     options['item_name'] = comment.item.name 
   end     
  end

  def invitation_to_gmail_friend(email, bcc, content, user)
   setup_template('bla', email, bcc, false) do |options|
     options['subject'] = 'The Hype invitation'
     footer = "\n\nThis message has been sent by #{user.email}"
     options['content'] = content + footer
   end     
  end
  
  def follow_request(receiver, sender)
   setup_template('request_to_follow', receiver.email) do |options|
     options['sender'] = sender
   end     
  end
  
  private

    def setup_user_notification_email(name, user)
      setup_template(name, user.email) do |options|
        options['user'] = user
      end
    end
end
