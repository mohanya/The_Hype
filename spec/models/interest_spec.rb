require 'spec_helper'

describe Interest do
  
  it "should create a new instance given valid attributes" do
    Factory.build(:interest).should be_valid
  end
  
  it "should require pos" do
    Factory.build(:interest, :pos => nil).should_not be_valid
  end
  
  it "should strip name before save" do
    interest = Factory.create(:interest, :name => " parenting ")
    interest.should be_valid
    interest.name.should == "parenting"
  end
end
