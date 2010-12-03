require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::ProfilesController do
  fixtures :users
  
  before(:each) do
    login_as(:josh)
  end

  describe "GET 'index'" do
    it "should be successful" do
      get 'index'
      response.should be_success
    end
  end

  # describe "GET 'destroy'" do
  #   it "should be successful" do
  #     get 'destroy'
  #     response.should be_success
  #   end
  # end
  # 
  # describe "GET 'referrals'" do
  #   it "should be successful" do
  #     get 'referrals'
  #     response.should be_success
  #   end
  # end
  # 
  # describe "GET 'subscribers'" do
  #   it "should be successful" do
  #     get 'subscribers'
  #     response.should be_success
  #   end
  # end
end
