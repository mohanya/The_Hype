require 'spec_helper'

FakeWeb.allow_net_connect = true

describe Api::ItemsController do
  integrate_views
  
  before(:all) do
    User.destroy_all
    Profile.destroy_all
    Item.any_instance.stubs(:reindex_sunspot).returns(true)
    Item.any_instance.stubs(:item_image).returns("/images/app/icon_hype_large.png")
  end

  it "should return JSON response with index of items and all required attributes" do
    @category = Factory.create(:item_category, :name => "event", :api_source => "event")
    @item = Factory.create(:item, :category_id => "event", :name => "Test Item")
    @item[:address] = "NYC"
    @item[:start_datetime] = Time.now + 1.week
    @item.save
    user = Factory.create(:user)
    @comment = Factory.create(:item_comment, :user_id => user.id, :item_id => @item.id)
    @comment.send(:update_item_comment_count)
    Factory.create(:review, :user_id => user.id, :item_id => @item.id)
    
    get :index, :format => :json
    response.status.should == "200 OK"
    response.request.env['REQUEST_URI'].should == "/api/items.json"
    response.body.should_not == " "
    json = JSON.parse(response.body)
    json["objects"].size.should == 1
    json["objects"][0]["item"]["name"].should == "Test Item"
    json["objects"][0]["item"]["id"].should == 1
    json["objects"][0]["item"]["thumbnail_url"].should == "http://test.thehypenetworks.com/images/app/icon_hype_large.png"
    json["objects"][0]["item"]["full_description"].should == 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.'
    json["objects"][0]["item"]["short_description"].should == 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.'
    json["objects"][0]["item"]["description_source_url"].should == 'http://www.source.com'
    json["objects"][0]["item"]["created_at"].should_not == nil
    json["objects"][0]["item"]["updated_at"].should_not == nil
    json["objects"][0]["item"]["item_type_tag"].should == "event"
    json["objects"][0]["item"]["item_type_id"].should == @category.integer_id
    json["objects"][0]["item"]["location"].should == "NYC"
    json["objects"][0]["item"]["event_time"].should_not == nil
    json["objects"][0]["item"]["comments_count"].should == 1
    json["objects"][0]["item"]["shares_count"].should == nil
    json["objects"][0]["item"]["hypes_count"].should == 1
    json["objects"][0]["item"]["last_hyped"].should_not == nil
    json["objects"][0]["item"]["score"].should == 3.0
    json["objects"][0]["item"]["average_metric_ratings"].should_not == nil
    json["objects"][0]["item"]["average_metric_ratings"][0]["metric_tag"].should == 'Quality'
    json["objects"][0]["item"]["average_metric_ratings"][0]["rating"].should == 3.0
    json["objects"][0]["item"]["average_metric_ratings"][1]["metric_tag"].should == 'Value'
    json["objects"][0]["item"]["average_metric_ratings"][1]["rating"].should == 3.0
    json["objects"][0]["item"]["average_metric_ratings"][2]["metric_tag"].should == 'Utility'
    json["objects"][0]["item"]["average_metric_ratings"][2]["rating"].should == 3.0
    json["paging"]["per_page"].should == 10
    json["paging"]["total_pages"].should == 1
    json["paging"]["page"].should == 1
  end
  
  it "should return items in a default order" do
    Factory.create(:item, :name => "Newest Item", :created_at => Time.now + 2.days)
    get :index, :format => :json
    response.status.should == "200 OK"
    response.request.env['REQUEST_URI'].should == "/api/items.json"
    response.body.should_not == " "
    json = JSON.parse(response.body)
    json["objects"][0]["item"]["name"].should == "Newest Item"
    json["objects"].size.should == 2
  end

  it "should return most hyped items" do
    Factory.create(:item, :name => "Most Hyped Item", :review_count => 2, :created_at => Time.now - 2.days)
    Item.any_instance.stubs(:review_count).returns(2)
    get :index, :format => :json, :most_hyped => true
    response.status.should == "200 OK"
    response.request.env['REQUEST_URI'].should == "/api/items.json?most_hyped=true"
    response.body.should_not == " "
    json = JSON.parse(response.body)
    json["objects"][0]["item"]["name"].should == "Most Hyped Item"
    json["objects"][0]["item"]["hypes_count"].should == 2
    json["objects"].size.should == 3   
  end
  
  it "should return top rated items" do
    Factory.create(:item, :name => "Top Rated Item", :score => 5.0, :created_at => Time.now - 2.days)
    get :index, :format => :json, :top_Rated => true
    response.status.should == "200 OK"
    response.request.env['REQUEST_URI'].should == "/api/items.json?top_Rated=true"
    response.body.should_not == " "
    json = JSON.parse(response.body)
    json["objects"][0]["item"]["name"].should == "Top Rated Item"
    json["objects"][0]["item"]["score"].should == 5.0
    json["objects"].size.should == 4
  end
  
  it "should return one item with details" do
    item = Item.first
    Item.any_instance.stubs(:sum_label_counts).returns(30)
    Factory.create(:item_media, :item_id => item.id)
    Factory.create(:item_media, :item_id => item.id)
    ItemMedia.any_instance.stubs(:image_url).returns("http://test.thehypenetworks.com/images/app/icon_hype_large.png")
    details = Factory.create(:item_detail, :feature_group => "lorem", :features => {:ipsum => "dolor", :sit => "amet"})
    item.item_details << details
    details = Factory.create(:item_detail, :feature_group => "consectetur", :features => {:adipiscing => "elit"})
    item.item_details << details
    item.save
    user1 = Factory.create(:user)
    review1 = Review.first
    Factory.create(:label, :type => "pro", :tag => "Tag_A", :user_id => user1.id, :item_id => item.id, :review_id => review1.id)
    Factory.create(:label, :type => "pro", :tag => "Tag_B", :user_id => user1.id, :item_id => item.id, :review_id => review1.id)
    Factory.create(:label, :type => "pro", :tag => "Tag_C", :user_id => user1.id, :item_id => item.id, :review_id => review1.id)
    Factory.create(:label, :type => "con", :tag => "Tag_D", :user_id => user1.id, :item_id => item.id, :review_id => review1.id)
    Factory.create(:label, :type => "con", :tag => "Tag_E", :user_id => user1.id, :item_id => item.id, :review_id => review1.id)
    Factory.create(:label, :type => "con", :tag => "Tag_F", :user_id => user1.id, :item_id => item.id, :review_id => review1.id)
    user2 = Factory.create(:user)
    review2 = Factory.create(:review, :user_id => user2.id, :item_id => item.id)
    Factory.create(:label, :type => "pro", :tag => "Tag_B", :user_id => user2.id, :item_id => item.id, :review_id => review2.id)
    Factory.create(:label, :type => "con", :tag => "Tag_E", :user_id => user2.id, :item_id => item.id, :review_id => review2.id)
    
    get :show, :id => 1, :format => :json
    response.status.should == "200 OK"
    response.request.env['REQUEST_URI'].should == "/api/items/1.json"
    response.body.should_not == " "
    json = JSON.parse(response.body)
    json["object"]["item"]["name"].should == "Test Item"  
    json["object"]["item"]["id"].should == 1
    json["object"]["item"]["thumbnail_url"].should == "http://test.thehypenetworks.com/images/app/icon_hype_large.png"
    json["object"]["item"]["full_description"].should == 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.'
    json["object"]["item"]["short_description"].should == 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.'
    json["object"]["item"]["description_source_url"].should == 'http://www.source.com'
    json["object"]["item"]["created_at"].should_not == nil
    json["object"]["item"]["updated_at"].should_not == nil
    json["object"]["item"]["item_type_tag"].should == "event"
    json["object"]["item"]["item_type_id"].should == 1
    json["object"]["item"]["location"].should == "NYC"
    json["object"]["item"]["event_time"].should_not == nil
    json["object"]["item"]["comments_count"].should == 1
    json["object"]["item"]["shares_count"].should == nil
    json["object"]["item"]["hypes_count"].should == 2
    json["object"]["item"]["last_hyped"].should_not == nil
    json["object"]["item"]["score"].should == 3.0
    json["object"]["item"]["average_metric_ratings"].should_not == nil
    json["object"]["item"]["average_metric_ratings"][0]["metric_tag"].should == 'Quality'
    json["object"]["item"]["average_metric_ratings"][0]["rating"].should == 3.0
    json["object"]["item"]["average_metric_ratings"][1]["metric_tag"].should == 'Value'
    json["object"]["item"]["average_metric_ratings"][1]["rating"].should == 3.0
    json["object"]["item"]["average_metric_ratings"][2]["metric_tag"].should == 'Utility'
    json["object"]["item"]["average_metric_ratings"][2]["rating"].should == 3.0
    json["object"]["item"]["meter"]["id"].should == 1
    json["object"]["item"]["meter"]["item_id"].should == 1
    json["object"]["item"]["meter"]["value"].should == 0
    json["object"]["item"]["meter"]["reading"].should == "Cool"
    json["object"]["item"]["meter"]["updated_at"].should_not == nil 
    json["object"]["item"]["meter"]["small_image_width"].should == 385
    json["object"]["item"]["meter"]["small_image_height"].should == 184
    json["object"]["item"]["meter"]["small_image_url"].should_not == nil
    json["object"]["item"]["meter"]["large_image_width"].should == 385
    json["object"]["item"]["meter"]["large_image_height"].should == 184
    json["object"]["item"]["meter"]["large_image_url"].should_not == nil
    json["object"]["item"]["sentiment"]["id"].should == 1
    json["object"]["item"]["sentiment"]["item_id"].should == 1
    json["object"]["item"]["sentiment"]["small_image_width"].should == 453
    json["object"]["item"]["sentiment"]["small_image_height"].should == 226
    json["object"]["item"]["sentiment"]["small_image_url"].should_not == nil
    json["object"]["item"]["sentiment"]["large_image_width"].should == 453
    json["object"]["item"]["sentiment"]["large_image_height"].should == 226
    json["object"]["item"]["sentiment"]["large_image_url"].should_not == nil
    json["object"]["item"]["sentiment"]["updated_at"].should_not == nil 
    json["object"]["item"]["sentiment"]["percent_positive"].should_not == nil #float (2.0) 
    json["object"]["item"]["buzz"]["id"].should ==1
    json["object"]["item"]["buzz"]["item_id"].should == 1
    json["object"]["item"]["buzz"]["small_image_width"].should == 220
    json["object"]["item"]["buzz"]["small_image_height"].should == 150
    json["object"]["item"]["buzz"]["small_image_url"].should_not == nil
    json["object"]["item"]["buzz"]["large_image_width"].should == 529
    json["object"]["item"]["buzz"]["large_image_height"].should == 360
    json["object"]["item"]["buzz"]["large_image_url"].should_not == nil
    json["object"]["item"]["buzz"]["updated_at"].should_not == nil    
    json["object"]["item"]["images"][0]["id"].should == 1
    json["object"]["item"]["images"][0]["item_id"].should == 1
    json["object"]["item"]["images"][0]["updated_at"].should_not == nil
    json["object"]["item"]["images"][0]["caption"].should == "Photo_1"
    json["object"]["item"]["images"][0]["thumbnail_url"].should == "http://test.thehypenetworks.com/images/app/icon_hype_large.png"
    json["object"]["item"]["images"][0]["large_image_url"].should == "http://test.thehypenetworks.com/images/app/icon_hype_large.png"
    json["object"]["item"]["images"][0]["small_image_url"].should == "http://test.thehypenetworks.com/images/app/icon_hype_large.png"
    json["object"]["item"]["images"][1]["id"].should == 1
    json["object"]["item"]["images"][1]["item_id"].should == 1
    json["object"]["item"]["images"][1]["updated_at"].should_not == nil
    json["object"]["item"]["images"][1]["caption"].should == "Photo_2"
    json["object"]["item"]["images"][1]["thumbnail_url"].should == "http://test.thehypenetworks.com/images/app/icon_hype_large.png"
    json["object"]["item"]["images"][1]["large_image_url"].should == "http://test.thehypenetworks.com/images/app/icon_hype_large.png"
    json["object"]["item"]["images"][1]["small_image_url"].should == "http://test.thehypenetworks.com/images/app/icon_hype_large.png"
    json["object"]["item"]["spec_categories"][0]["id"].should == 1 
    json["object"]["item"]["spec_categories"][0]["item_id"].should == 1 
    json["object"]["item"]["spec_categories"][0]["name"].should == "lorem"
    json["object"]["item"]["spec_categories"][0]["updated_at"].should_not == nil
    json["object"]["item"]["spec_categories"][0]["specs"][0]["id"].should == 1
    json["object"]["item"]["spec_categories"][0]["specs"][0]["spec_category_id"].should == 1
    json["object"]["item"]["spec_categories"][0]["specs"][0]["name"].should == "ipsum"
    json["object"]["item"]["spec_categories"][0]["specs"][0]["value"].should == "dolor"
    json["object"]["item"]["spec_categories"][0]["specs"][0]["updated_at"].should_not == nil
    json["object"]["item"]["spec_categories"][0]["specs"][1]["id"].should == 2
    json["object"]["item"]["spec_categories"][0]["specs"][1]["spec_category_id"].should == 1
    json["object"]["item"]["spec_categories"][0]["specs"][1]["name"].should == "sit"
    json["object"]["item"]["spec_categories"][0]["specs"][1]["value"].should == "amet"
    json["object"]["item"]["spec_categories"][0]["specs"][1]["updated_at"].should_not == nil
    json["object"]["item"]["spec_categories"][1]["id"].should == 2 
    json["object"]["item"]["spec_categories"][1]["item_id"].should == 1 
    json["object"]["item"]["spec_categories"][1]["name"].should == "consectetur"
    json["object"]["item"]["spec_categories"][1]["updated_at"].should_not == nil
    json["object"]["item"]["spec_categories"][1]["specs"][0]["spec_category_id"].should == 2
    json["object"]["item"]["spec_categories"][1]["specs"][0]["name"].should == "adipiscing"
    json["object"]["item"]["spec_categories"][1]["specs"][0]["value"].should == "elit"
    json["object"]["item"]["spec_categories"][1]["specs"][0]["updated_at"].should_not == nil
    json["object"]["item"]["top_pros"][0]["id"].should == 0
    json["object"]["item"]["top_pros"][0]["text"].should == "Tag_B"
    json["object"]["item"]["top_pros"][0]["type"].should == "Pro"
    json["object"]["item"]["top_pros"][0]["count"].should == 2
    json["object"]["item"]["top_pros"][0]["item_id"].should == 1
    json["object"]["item"]["top_pros"][0]["created_at"].should_not == nil
    json["object"]["item"]["top_pros"][0]["updated_at"].should_not == nil
    json["object"]["item"]["top_pros"][1]["id"].should == 1
    json["object"]["item"]["top_pros"][1]["text"].should == "Tag_A"
    json["object"]["item"]["top_pros"][1]["type"].should == "Pro"
    json["object"]["item"]["top_pros"][1]["count"].should == 1
    json["object"]["item"]["top_pros"][1]["item_id"].should == 1
    json["object"]["item"]["top_pros"][1]["created_at"].should_not == nil
    json["object"]["item"]["top_pros"][1]["updated_at"].should_not == nil
    json["object"]["item"]["top_pros"][2]["id"].should == 2
    json["object"]["item"]["top_pros"][2]["text"].should == "Tag_C"
    json["object"]["item"]["top_pros"][2]["type"].should == "Pro"
    json["object"]["item"]["top_pros"][2]["count"].should == 1
    json["object"]["item"]["top_pros"][2]["item_id"].should == 1
    json["object"]["item"]["top_pros"][2]["created_at"].should_not == nil
    json["object"]["item"]["top_pros"][2]["updated_at"].should_not == nil
    json["object"]["item"]["top_cons"][0]["id"].should == 0
    json["object"]["item"]["top_cons"][0]["text"].should == "Tag_E"    
    json["object"]["item"]["top_cons"][0]["type"].should == "Con"
    json["object"]["item"]["top_cons"][0]["count"].should == 2
    json["object"]["item"]["top_cons"][0]["item_id"].should == 1
    json["object"]["item"]["top_cons"][0]["created_at"].should_not == nil
    json["object"]["item"]["top_cons"][0]["updated_at"].should_not == nil
    json["object"]["item"]["top_cons"][1]["id"].should == 1
    json["object"]["item"]["top_cons"][1]["text"].should == "Tag_D"    
    json["object"]["item"]["top_cons"][1]["type"].should == "Con"
    json["object"]["item"]["top_cons"][1]["count"].should == 1
    json["object"]["item"]["top_cons"][1]["item_id"].should == 1
    json["object"]["item"]["top_cons"][1]["created_at"].should_not == nil
    json["object"]["item"]["top_cons"][1]["updated_at"].should_not == nil
    json["object"]["item"]["top_cons"][2]["id"].should == 2
    json["object"]["item"]["top_cons"][2]["text"].should == "Tag_F"    
    json["object"]["item"]["top_cons"][2]["type"].should == "Con"
    json["object"]["item"]["top_cons"][2]["count"].should == 1
    json["object"]["item"]["top_cons"][2]["item_id"].should == 1
    json["object"]["item"]["top_cons"][2]["created_at"].should_not == nil
    json["object"]["item"]["top_cons"][2]["updated_at"].should_not == nil
  end
  
  it "should search for an item" do
    get :index, :search => 'Hype', :format => :json
    response.status.should == "200 OK"
    response.request.env['REQUEST_URI'].should == "/api/items.json?search=Hype"
    response.body.should_not == " "
    json = JSON.parse(response.body)
    json["objects"].size.should == 1
    json["objects"][0]["item"]["name"].should == "Most Hyped Item"
  end
  
  it "should search for an item and ignore case" do
    get :index, :search => 'hype', :format => :json
    response.status.should == "200 OK"
    response.request.env['REQUEST_URI'].should == "/api/items.json?search=hype"
    response.body.should_not == " "
    json = JSON.parse(response.body)
    json["objects"].size.should == 1
    json["objects"][0]["item"]["name"].should == "Most Hyped Item"
  end
  
  it "should search for an item and ignore blank query" do
    get :index, :search => ' ', :format => :json
    response.status.should == "200 OK"
    response.body.should_not == " "
    json = JSON.parse(response.body)
    json["objects"].size.should == 4
    json["objects"][0]["item"]["name"].should == "Newest Item"
  end

  it "should paginate" do
    i = 1
    15.times do 
      Factory.create(:item, :created_at => Time.now - i.days) 
      i += 1
    end
    Item.count.should == 19 # 4 + 15
    get :index, :page => 1, :per_page => 10, :format => :json
    response.status.should == "200 OK"
    response.request.env['REQUEST_URI'].should == "/api/items.json?page=1&per_page=10"
    response.body.should_not == " "
    json = JSON.parse(response.body)
    json["objects"].size.should == 10
    json["objects"][0]["item"]["name"].should == "Newest Item"
    
    get :index, :page => 2, :per_page => 10, :format => :json
    json = JSON.parse(response.body)
    json["objects"].size.should == 9
    json["objects"][0]["item"]["name"].should_not == "Newest Item"
    
    get :index, :page => 1, :per_page => 10, :format => :json, :top_Rated => true
    json = JSON.parse(response.body)
    json["objects"].size.should == 10
    json["objects"][0]["item"]["name"].should == "Top Rated Item"
    
    get :index, :page => 2, :per_page => 10, :format => :json, :top_Rated => true
    json = JSON.parse(response.body)
    json["objects"].size.should == 9
    json["objects"][0]["item"]["name"].should_not == "Top Rated Item"
    
    get :index, :page => 1, :per_page => 10, :format => :json, :most_hyped => true
    json = JSON.parse(response.body)
    json["objects"].size.should == 10
    json["objects"][0]["item"]["name"].should == "Test Item"
    
    get :index, :page => 2, :per_page => 10, :format => :json, :most_hyped => true
    json = JSON.parse(response.body)
    json["objects"].size.should == 9
    json["objects"][0]["item"]["name"].should_not == "Test Item"
  end
end








