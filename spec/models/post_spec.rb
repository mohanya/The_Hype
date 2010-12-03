require File.dirname(__FILE__) + '/../spec_helper'

describe Post do

  it "should be valid" do
    @post = Factory(:post)
    @post.should be_valid
  end
  
  describe "with validations" do
    
    it "should require title" do
      post = Factory.build(:post, :title => nil)
      post.should_not be_valid
    end
    
    it "should require a body" do
      post = Factory.build(:post, :body => nil)
      post.should_not be_valid
    end
    
    it "should require an author" do
      post = Factory.build(:post, :author => nil)
      post.should_not be_valid
    end
  end
  
  describe "with publishing" do
    
    before do
      @post = Factory(:post, :state => nil)
    end
    
    it "should be unpublished by default" do
      @post.state.should == "draft"
    end
    
    it "should set a published date when published" do
      lambda {
        @post.publish!
        @post.reload
      }.should change(@post, :posted_at)
    end
    
    it "should publish when told to publish!" do
      @post.publish!
      @post.state.should == "published"
    end
    
    it "should set the published date if we set the state published" do
      lambda {
        @post.state = "published"
        @post.save
      }.should change(@post, :posted_at)
    end
    
  end
  
end
