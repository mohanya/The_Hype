require 'spec_helper'

describe TrustedBrand do
  it "should create a new instance given valid attributes" do
    Factory.build(:trusted_brand).should be_valid
  end
  
  it "should require pos" do
    Factory.build(:trusted_brand, :pos => nil).should_not be_valid
  end
  
  it "should strip name before save" do
    trusted_brand = Factory.create(:trusted_brand, :name => " apple ")
    trusted_brand.should be_valid
    trusted_brand.name.should == "apple"
  end
  
end
