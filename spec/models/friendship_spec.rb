require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Friendship do

  it "should require user" do
    friendship = Factory.build(:friendship, :user => nil)
    friendship.should_not be_valid
    friendship.should have(1).error_on(:user)
  end

  it "should require friend" do
    friendship = Factory.build(:friendship, :friend => nil)
    friendship.should_not be_valid
    friendship.should have(1).error_on(:friend)
  end

end
