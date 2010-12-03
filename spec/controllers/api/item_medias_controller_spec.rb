require 'spec_helper'

FakeWeb.allow_net_connect = true

describe Api::ItemMediasController do
  integrate_views
  
  it "should return images of item" do
    Item.any_instance.stubs(:reindex_sunspot).returns(true)
    Factory.create(:item_category, :name => "event", :api_source => "event")
    item = Factory.create(:item, :category_id => "event", :name => "Test Item")
    Factory.create(:item_media, :item_id => item.id)
    Factory.create(:item_media, :item_id => item.id)
    ItemMedia.any_instance.stubs(:image_url).returns("http://thehype.com/images/app/icon_hype_large.png")
    get :index, :item_id => 1, :format => :json
    response.request.env['REQUEST_URI'].should == "/api/items/1/images.json"
    json = JSON.parse(response.body)
    #json["objects"][0]["image"]["id"].should == 1 # needed?
    json["objects"][0]["image"]["item_id"].should == 1
    json["objects"][0]["image"]["updated_at"].should_not == ''
    json["objects"][0]["image"]["caption"].should =~ /Photo/
    json["objects"][0]["image"]["thumbnail_url"].should == "http://thehype.com/images/app/icon_hype_large.png"
    json["objects"][0]["image"]["large_image_url"].should == "http://thehype.com/images/app/icon_hype_large.png"
    json["objects"][0]["image"]["small_image_url"].should == "http://thehype.com/images/app/icon_hype_large.png"
    #json["objects"][1]["image"]["id"].should == 2
    json["objects"][1]["image"]["item_id"].should == 1
    json["objects"][1]["image"]["updated_at"].should_not == ''
    json["objects"][0]["image"]["caption"].should =~ /Photo/
    json["objects"][1]["image"]["thumbnail_url"].should == "http://thehype.com/images/app/icon_hype_large.png"
    json["objects"][1]["image"]["large_image_url"].should == "http://thehype.com/images/app/icon_hype_large.png"
    json["objects"][1]["image"]["small_image_url"].should == "http://thehype.com/images/app/icon_hype_large.png"
  end
  
end
