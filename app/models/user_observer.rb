class UserObserver < ActiveRecord::Observer
  def after_create(user)
    UserMailer.delay.deliver_signup_notification(user) unless (user.admin? && User.count == 1)
  end

  #def after_save(user)
  #  if user.active? && !user.sent_activation?
  #    UserMailer.delay.deliver_activation(user)
  #  end
  #end
  
end
