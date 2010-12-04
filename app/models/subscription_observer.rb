class SubscriptionObserver < ActiveRecord::Observer

  def after_create(subscription)
    profile = subscription.profile
    Delayed::Job.enqueue AddSubscriberJob.new(profile.email, profile.fullname.to_s)
  end

end
