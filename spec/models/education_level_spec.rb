require 'spec_helper'

describe EducationLevel do
  before(:each) do
    @valid_attributes = {
      :name => "value for label"
    }
  end

  it "should create a new instance given valid attributes" do
    EducationLevel.create!(@valid_attributes)
  end
end
