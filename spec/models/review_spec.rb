require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Review do

  def build_review(options = {})
    Review.make_unsaved({:user_id => User.make.id, :item_id => Item.make.id}.merge(options))
  end

  def create_review(options = {})
    review = build_review(options)
    review.save
    review  
    # build_review.tap do |review|
      # review.save
    # end
  end

  it "should create create a valid review" do
    review = build_review
    review.save.should == true
  end


  # it "should enqueue calculate score after review is saved" do
  #   lambda {
  #     Factory(:review)
  #   }.should change(Delayed::Job, :count).by(2)
  # 
  # end
  
  it "should calculate peer approval score" do
    pending
    review = create_review
    review.save.should == true
    review.helpful_user_ids = [1]
    review.unhelpful_user_ids = [2,3,4]
      
    review.peer_approval.should == 0.25
    
    review.helpful_user_id = 5  
    review.save.should == true 
    review.helpful_user_id = 6    
    review.save  
    review.reload
    review.peer_approval.should == 0.5
  end
  
  it "peer approval score when no peer reviews" do
    review = create_review
    review.peer_approval.should == 0
  end
  
  it "should remove unhelpful when a user decides a review is actually helpful" do
    pending
    review = create_review
    review.helpful_user_ids = [1,2]
    review.unhelpful_user_ids = [3,4]
    
    review.helpful_user_id = 4
    review.save
    
    review.helpful_user_ids.should == [1,2,4]
    review.unhelpful_user_ids.should == [3]    
  end
  
  it "should remove helpful when a user decides a review is actually unhelpful" do
    pending
    review = create_review
    review.helpful_user_ids = [1,2]
    review.unhelpful_user_ids = [3,4]
    
    review.unhelpful_user_id = 1
    review.save
    
    review.helpful_user_ids.should == [2]
    review.unhelpful_user_ids.should == [3,4,1]    
  end
end
