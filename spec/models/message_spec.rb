require 'spec_helper'

describe Message do
  it "is valid given valid attributes" do
    Factory.build(:message).should be_valid
  end
  
  it { should belong_to(:sender) }
  it { should belong_to(:receiver) }
  
  it { should validate_presence_of(:sender_id) }
  it { should validate_presence_of(:receiver_id) }
  it { should validate_presence_of(:subject) }
  it { should validate_presence_of(:body) }
  
  describe ".unread" do
    before :each do
      @unread = (1..2).map{ Factory(:message, :read => false) }
      @read = (1..2).map{ Factory(:message, :read => true) }
    end

    it "retrieves only unread messages" do
      (Message.unread.to_a - @unread).should be_empty
    end
  end
end
