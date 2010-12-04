class InviteMailer < Mailer
  
  def invite_notification(invite)
    setup_template('invitation', invite.email) do |options|
        options['string_id'] =  "#{Digest::SHA1.hexdigest Time.now.to_s}-#{invite.id}"
    end
    invite.update_attribute(:sent_at, Time.now)
  end
end
