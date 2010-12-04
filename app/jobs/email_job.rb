class EmailJob
  attr_accessor :emails, :body, :user

  def initialize(emails, body, user)
    self.body = body
    self.emails = emails
    self.user = user
  end

  def perform
    email = emails.pop 
    UserMailer.deliver_invitation_to_gmail_friend(email, emails, body, user)
  end
end
