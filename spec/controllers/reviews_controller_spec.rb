require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ReviewsController do
  fixtures :users

  before(:each) do
    login_as(:josh)
  end

  #Delete these examples and add some real ones
  it "should use ReviewsController" do
    controller.should be_an_instance_of(ReviewsController)
  end


  describe "GET 'new'" do
    it "should be successful" do
      # item = Factory(:item)
      item = Item.make
      get 'new' , :item_id => item.id
      response.should be_success
    end
  end
end
