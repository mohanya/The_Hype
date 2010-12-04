require File.dirname(__FILE__) + '/../spec_helper'

describe SubscriptionObserver do
  
  before do
    @subscription = Factory(:subscription)
  end
  
  it "should create add subscriber delayed job" do
    @subscription = Factory(:subscription)
    lambda {
      SubscriptionObserver.instance.after_create(@subscription)
    }.should change(Delayed::Job, :count).by(1)
  end
  
  it "should create job with given profile" do
    profile = @subscription.profile
    # This creates a real object that responds to #perform method call so DelayedJob does not crash in test
    job = AddSubscriberJob.new(:email => 'blah', :name => 'hello')
    
    AddSubscriberJob.should_receive(:new).with(profile.email, profile.fullname.to_s).and_return(job)
    
    SubscriptionObserver.instance.after_create(@subscription)
  end
end