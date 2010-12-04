require File.dirname(__FILE__) + '/../spec_helper'

describe AddSubscriberJob do
  
  it "should add subscriber to campaign monitor" do
    cm = mock(CampaignMonitor)
    CampaignMonitor.should_receive(:new).and_return(cm)
    cm.should_receive(:add_subscriber).with('123', 'admin@hello.com', 'xmen')
    
    AddSubscriberJob.new('admin@hello.com', 'xmen').perform
  end

end