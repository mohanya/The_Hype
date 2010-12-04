require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SearchesController do

  #Delete these examples and add some real ones
  it "should use SearchesController" do
    controller.should be_an_instance_of(SearchesController)
  end
    
  describe "GET 'show'" do
    it "should be successful" do
      stub_get("http://sandbox.api.shopping.com/publisher/3.0/rest/GeneralSearch?apiKey=authorized-key&trackingId=7000610&pageNumber=1&numItems=10&keyword=canon", "shopping_general_search.xml")
      get 'show', :query => "canon"
      response.should be_success
    end
  end
  
end
