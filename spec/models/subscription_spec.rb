require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Subscription do
  describe "associations" do
    it "should belong to profile" do
      Factory(:subscription).should belong_to(:profile)
    end
  end
  
  describe "mandatory fields" do
    it "should require signup ip address" do
      subscription = Factory.build(:subscription, :signup_ip_address => nil)
      subscription.should_not be_valid
      subscription.should have(1).error_on(:signup_ip_address)
    end

    it "should require profile" do
      subscription = Factory.build(:subscription, :profile => nil)
      subscription.should_not be_valid
      subscription.should have(1).error_on(:profile)
    end
  end

  describe "with observers on" do
    it "should create add subscriber delayed job" do
      Delayed::Job.should_receive(:enqueue)
      AddSubscriberJob.should_receive(:new)
      Subscription.with_observers(:subscription_observer) do
        Factory(:subscription)
      end
    end
  end

  describe "before create hooks" do
    it "should set subscribed_at" do
      subscription = Subscription.new(:profile => Factory(:profile), :signup_ip_address => '123')
      subscription.subscribed_at.should be_nil
      subscription.save
      subscription.subscribed_at.should_not be_nil
    end
  end
end
