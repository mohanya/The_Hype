require 'spec_helper'

FakeWeb.allow_net_connect = true

describe Api::CommentsController do
  integrate_views
  
  before(:all) do
    User.destroy_all
    @user1 = Factory.create(:user)
    Item.any_instance.stubs(:reindex_sunspot).returns(true)
    Item.any_instance.stubs(:item_image).returns("/images/app/icon_hype_large.png")
    @category = Factory.create(:item_category, :name => "event", :api_source => "event")
    @item = Factory.create(:item, :category_id => "event", :name => "Test Item")
    @item[:address] = "NYC"
    @item[:start_datetime] = Time.now + 1.week
    @item.save
    @another_item = Factory.create(:item, :category_id => "event")
    @comment = Factory.create(:item_comment, :user_id => @user1.id, :item_id => @item.id, :comment_text => "first comment", :created_at => Time.now)
    @comment.send(:update_item_comment_count)
  end

  it "should list comments" do
    Factory.create(:item_comment, :user_id => @user1.id, :item_id => @item.id, :comment_text => "second comment", :created_at => Time.now + 10.minutes)
    Factory.create(:item_comment, :user_id => @user1.id, :item_id => @another_item.id)
    @review = Factory.create(:review, 
      :user_id => @user1.id, 
      :item_id => @item.id, 
      :description => "some description A", 
      :first_word_list => "first words A",
      :criteria_1 => 5.0,
      :criteria_2 => 4.0,
      :criteria_3 => 3.0
    )
    get :index, :item_id => 1, :format => :json
    response.request.env['REQUEST_URI'].should == "/api/items/1/comments.json"
    json = JSON.parse(response.body)
    json["context"]["item"]["name"].should == "Test Item"
    json["context"]["item"]["id"].should == 1
    json["context"]["item"]["thumbnail_url"].should == "http://test.thehypenetworks.com/images/app/icon_hype_large.png"
    json["context"]["item"]["full_description"].should == 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.'
    json["context"]["item"]["short_description"].should == 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.'
    json["context"]["item"]["description_source_url"].should == 'http://www.source.com'
    json["context"]["item"]["created_at"].should_not == nil
    json["context"]["item"]["updated_at"].should_not == nil
    json["context"]["item"]["item_type_tag"].should == "event"
    json["context"]["item"]["item_type_id"].should == @category.integer_id
    json["context"]["item"]["location"].should == "NYC"
    json["context"]["item"]["event_time"].should_not == nil
    json["context"]["item"]["comments_count"].should == 1
    json["context"]["item"]["shares_count"].should == nil
    json["context"]["item"]["hypes_count"].should > 0
    json["context"]["item"]["last_hyped"].should_not == nil
    json["context"]["item"]["score"].should == 4.0
    json["context"]["item"]["average_metric_ratings"].should_not == nil
    json["context"]["item"]["average_metric_ratings"][0]["metric_tag"].should == 'Quality'
    json["context"]["item"]["average_metric_ratings"][0]["rating"].should == 5.0
    json["context"]["item"]["average_metric_ratings"][1]["metric_tag"].should == 'Value'
    json["context"]["item"]["average_metric_ratings"][1]["rating"].should == 4.0
    json["context"]["item"]["average_metric_ratings"][2]["metric_tag"].should == 'Utility'
    json["context"]["item"]["average_metric_ratings"][2]["rating"].should == 3.0
    json["objects"].size.should == 2
    json["objects"][0]["comment"]["id"].should == 2
    json["objects"][0]["comment"]["item_id"].should == 1
    json["objects"][0]["comment"]["user_id"].should == @user1.id
    json["objects"][0]["comment"]["user_name"].should == "Joe1 Shmoe1"
    json["objects"][0]["comment"]["user_thumbnail_url"].should == "http://test.thehypenetworks.com/images/default_male_thumb_avatar.png"
    json["objects"][0]["comment"]["created_at"].should_not == ""
    json["objects"][0]["comment"]["updated_at"].should_not == ""
    json["objects"][0]["comment"]["body"].should == "second comment"
    json["objects"][0]["comment"]["replies_count"].should == 0
    json["objects"][1]["comment"]["id"].should == 1
    json["objects"][1]["comment"]["item_id"].should == 1
    json["objects"][1]["comment"]["user_id"].should == @user1.id
    json["objects"][1]["comment"]["user_name"].should == "Joe1 Shmoe1"
    json["objects"][1]["comment"]["user_thumbnail_url"].should == "http://test.thehypenetworks.com/images/default_male_thumb_avatar.png"
    json["objects"][1]["comment"]["created_at"].should_not == ""
    json["objects"][1]["comment"]["updated_at"].should_not == ""
    json["objects"][1]["comment"]["body"].should == "first comment"
    json["objects"][1]["comment"]["replies_count"].should == 0
  end

  it "should list replies" do
    Factory.create(:item_comment, :user_id => @user1.id, :item_id => @item.id, :parent_id => @comment.id, :comment_text => "first reply", :created_at => Time.now + 30.minutes)
    Factory.create(:item_comment, :user_id => @user1.id, :item_id => @item.id, :parent_id => @comment.id, :comment_text => "second reply", :created_at => Time.now + 1.hour)
    get :index, :item_id => 1, :comment_id => 1, :format => :json
    response.request.env['REQUEST_URI'].should == "/api/items/1/comments/1/replies.json"
    json = JSON.parse(response.body)    
    json["context"]["comment"]["id"].should == 1
    json["context"]["comment"]["item_id"].should == 1
    json["context"]["comment"]["user_id"].should == @user1.id
    json["context"]["comment"]["user_name"].should == "Joe1 Shmoe1"
    json["context"]["comment"]["user_thumbnail_url"].should == "http://test.thehypenetworks.com/images/default_male_thumb_avatar.png"
    json["context"]["comment"]["created_at"].should_not == ""
    json["context"]["comment"]["updated_at"].should_not == ""
    json["context"]["comment"]["body"].should == "first comment"
    json["context"]["comment"]["replies_count"].should == 2
    json["objects"][0]["reply"]["id"].should == 4
    json["objects"][0]["reply"]["comment_id"].should == @comment.integer_id
    json["objects"][0]["reply"]["user_id"].should == @user1.id
    json["objects"][0]["reply"]["user_name"].should == "Joe1 Shmoe1"
    json["objects"][0]["reply"]["user_thumbnail_url"].should == "http://test.thehypenetworks.com/images/default_male_thumb_avatar.png"
    json["objects"][0]["reply"]["created_at"].should_not == ""
    json["objects"][0]["reply"]["updated_at"].should_not == ""
    json["objects"][0]["reply"]["body"].should == "second reply"
    json["objects"][0]["reply"]["item_id"].should == 1
    json["objects"][1]["reply"]["id"].should == 3
    json["objects"][1]["reply"]["comment_id"].should == @comment.integer_id
    json["objects"][1]["reply"]["user_id"].should == @user1.id
    json["objects"][1]["reply"]["user_name"].should == "Joe1 Shmoe1"
    json["objects"][1]["reply"]["user_thumbnail_url"].should == "http://test.thehypenetworks.com/images/default_male_thumb_avatar.png"
    json["objects"][1]["reply"]["created_at"].should_not == ""
    json["objects"][1]["reply"]["updated_at"].should_not == ""
    json["objects"][1]["reply"]["body"].should == "first reply"
    json["objects"][1]["reply"]["item_id"].should == 1
  end
  
  it "should create new comment" do
    Comment.destroy_all
    ItemComment.any_instance.stubs(:delayed_update_item_comment_count).returns(true)
    comment = {:user_id => @user1.id, :body => "new comment"}
    post :create, :item_id => 1, :comment => comment, :format => :json
    comment = Comment.first
    comment.comment_text.should == "new comment"
    comment.user_id.should == @user1.id
    comment.item_id.should == @item.id
    comment.integer_id.should == 1
    @item.comments.count.should == 1
  end
  
  it "should create new reply" do
    @comment = Comment.first
    ItemComment.any_instance.stubs(:delayed_update_item_comment_count).returns(true)
    reply = {:user_id => @user1.id, :body => "new reply"}
    post :create, :item_id => 0, :comment_id => @comment.integer_id, :reply => reply, :format => :json
    Comment.count.should == 2
    @comment.children.count.should == 1
    reply = @comment.children.first
    reply.comment_text.should == "new reply"
    reply.user_id.should == @user1.id
    reply.item_id.should == @item.id
    reply.integer_id.should == 2
    @item.comments.count.should == 2
  end
  
  it "should paginate comments" do
    i = 2 
    15.times do 
      Factory.create(:item_comment, :user_id => @user1.id, :item_id => @item.id, :created_at => Time.now - i.hours)
      i += 1
    end
    Comment.count.should == 17 # 2 + 15
    get :index, :page => 1, :per_page => 10, :item_id => @item.integer_id, :format => :json
    response.request.env['REQUEST_URI'].should == "/api/items/1/comments.json?page=1&per_page=10"
    json = JSON.parse(response.body)
    json["objects"].size.should == 10    
  end
  
  it "should paginate replies" do
    @comment = Comment.first
    i = 2
    15.times do 
      Factory.create(:item_comment, :user_id => @user1.id, :parent_id => @comment.id, :item_id => @item.id, :created_at => Time.now - i.hours)
      i += 1
    end
    @comment.children.count.should == 16
    get :index, :item_id => 1, :comment_id => 1, :page => 1, :per_page => 10, :format => :json
    response.request.env['REQUEST_URI'].should == "/api/items/1/comments/1/replies.json?page=1&per_page=10"
    json = JSON.parse(response.body)
    json["objects"].size.should == 10
  end

end