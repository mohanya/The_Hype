require 'spec_helper'

FakeWeb.allow_net_connect = true

describe Api::ActivitiesController do
  integrate_views
  
  before(:all) do
    User.destroy_all
    @user1 = Factory.create(:user)
    @user2 = Factory.create(:user)
    @user3 = Factory.create(:user)
    Item.any_instance.stubs(:reindex_sunspot).returns(true)
    Item.any_instance.stubs(:item_image).returns("/images/app/icon_hype_large.png")
    Factory.create(:item_category, :name => "event", :api_source => "event")
    @item = Factory.create(:item, :category_id => "event", :name => "Test Item")
    Factory.create(
      :activity, 
      :user_id => @user1.id, 
      :activity_date => Time.now - 2.hours, 
      :source_id_string => @item.id, 
      :description => "Added"    
    )
    Factory.create(
      :activity, 
      :user_id => @user2.id, 
      :activity_date => Time.now - 1.hour, 
      :source_id_string => @item.id, 
      :description => "Commented on"
    )
  end
  
  it "should display the public stream" do
    get :index, :format => :json
    response.request.env['REQUEST_URI'].should == "/api/events.json"
    json = JSON.parse(response.body)
    json["objects"].size.should == 2
    #json["objects"][0]["event"]["id"].should_not == nil # needed?
    json["objects"][0]["event"]["item_id"].should == @item.integer_id
    json["objects"][0]["event"]["created_at"].should_not == nil
    json["objects"][0]["event"]["updated_at"].should_not == nil
    json["objects"][0]["event"]["user_id"].should == @user2.id
    json["objects"][0]["event"]["user_name"].should == "Joe1 Shmoe1"
    json["objects"][0]["event"]["user_thumbnail_url"].should == "http://test.thehypenetworks.com/images/default_male_thumb_avatar.png"
    json["objects"][0]["event"]["item_name"].should == "Test Item"
    json["objects"][0]["event"]["item_type_tag"].should == "event"
    json["objects"][0]["event"]["item_thumbnail_url"].should == "http://test.thehypenetworks.com/images/app/icon_hype_large.png"
    json["objects"][0]["event"]["text"].should == "Commented on Test Item"
    #json["objects"][1]["event"]["id"].should_not == nil # needed?
    json["objects"][0]["event"]["item_id"].should == @item.integer_id
    json["objects"][1]["event"]["created_at"].should_not == nil
    json["objects"][1]["event"]["updated_at"].should_not == nil
    json["objects"][1]["event"]["user_id"].should == @user1.id
    json["objects"][1]["event"]["user_name"].should == "Joe1 Shmoe1"
    json["objects"][1]["event"]["user_thumbnail_url"].should == "http://test.thehypenetworks.com/images/default_male_thumb_avatar.png"
    json["objects"][1]["event"]["item_name"].should == "Test Item"
    json["objects"][1]["event"]["item_type_tag"].should == "event"
    json["objects"][1]["event"]["item_thumbnail_url"].should == "http://test.thehypenetworks.com/images/app/icon_hype_large.png"
    json["objects"][1]["event"]["text"].should == "Added Test Item"
  end
  
  it "should display the private stream" do
    Factory.create(:friendship, :user => @user3, :friend => @user1)
    get :index, :followings => @user3.id, :format => :json
    json = JSON.parse(response.body)
    json["objects"].size.should == 1
    #json["objects"][0]["event"]["id"].should_not == nil # needed?
    json["objects"][0]["event"]["item_id"].should == @item.integer_id
    json["objects"][0]["event"]["created_at"].should_not == nil
    json["objects"][0]["event"]["updated_at"].should_not == nil
    json["objects"][0]["event"]["user_id"].should == @user1.id
    json["objects"][0]["event"]["user_name"].should == "Joe1 Shmoe1"
    json["objects"][0]["event"]["user_thumbnail_url"].should == "http://test.thehypenetworks.com/images/default_male_thumb_avatar.png"
    json["objects"][0]["event"]["item_name"].should == "Test Item"
    json["objects"][0]["event"]["item_type_tag"].should == "event"
    json["objects"][0]["event"]["item_thumbnail_url"].should == "http://test.thehypenetworks.com/images/app/icon_hype_large.png"
    json["objects"][0]["event"]["text"].should == "Added Test Item"
  end
  
  it "should paginate stream" do
    i = 2
    15.times do 
      Factory.create(
        :activity, 
        :user_id => @user2.id, 
        :activity_date => Time.now - i.days, 
        :source_id_string => @item.id, 
        :description => "Commented on"
      )
      i += 1
    end
    Activity.count.should == 17 # 2 + 15
    get :index, :page => 1, :per_page => 10, :format => :json
    json = JSON.parse(response.body)
    json["objects"].size.should == 10
  end
  
end