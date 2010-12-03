require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ItemsController do
  fixtures :items
  fixtures :users

  # iphone improvements tests
  
  
  #before(:each) do
  #  login_as(:josh)
  #end

  #describe "GET 'index'" do
  #  begin
  #  Item.make
  #  it "should be successful" do
  #    get 'index'
  #    response.should be_success
  #  end
  #  rescue
  #  end
  #end

  #describe "GET 'show'" do
  #  it "should be successful" do
  #    i=Item.make
  #    url = /http:\/\/search.twitter.com\/search.json.*/
  #    stub_get url, 'twitter_search_iphone3gs.json'
  #    get 'show', :id => i.id
  #    response.should be_success
  #  end

  #  it "should return json" do
  #    xhr(:get, :show, :id => "ipod", :category => "product")
  #    assigns[:data].should == {:status => "not found"}
  #  end
  #end

  #describe "GET 'new'" do
  #  it "should be successful" do
  #    stub_get("http://sandbox.api.shopping.com/publisher/3.0/rest/GeneralSearch?apiKey=authorized-key&trackingId=7000610&keyword=canon&numItems=10", "shopping_general_search.xml")
  #    get 'new', :query => "canon"
  #    response.should be_success
  #  end
  #end

  #describe "GET 'edit'" do
  #  it "should be successful" do
  #    get 'edit', :id => '1'
  #    response.should be_success
  #  end
  #end
end
