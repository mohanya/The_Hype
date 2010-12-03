require 'spec_helper'

describe Friends::TwittersController do
  fixtures(:users)
  fixtures(:profiles)

  before do
    login_as(:quentin)
    @user = users(:quentin)

    @user.stub!("twitt!").and_return(true)
    controller.stub!(:current_user).and_return(@user)
  end

  describe "POST/create" do
    it "should render json with status and message" do
      expected_json = {:status => 'ok', :message => 'Your twitt has been sent'}.to_json

      post(:create)
      response.body.should == expected_json
    end

    it "should render json with error" do
      expected_json = {:status => 'error', :message => 'very strage error'}.to_json
      @user.stub!("twitt!").and_raise(StandardError.new('very strage error'))

      post(:create)
      response.body.should == expected_json
    end
  end

end
