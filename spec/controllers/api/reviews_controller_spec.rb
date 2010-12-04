require 'spec_helper'

FakeWeb.allow_net_connect = true

describe Api::ReviewsController do
  integrate_views
  
  before(:all) do
    User.destroy_all
    Profile.destroy_all
    Item.any_instance.stubs(:reindex_sunspot).returns(true)
    Item.any_instance.stubs(:item_image).returns("/images/app/icon_hype_large.png")
    @category = Factory.create(:item_category, :name => "event", :api_source => "event")
    @item = Factory.create(:item, :category_id => "event")
    @item[:address] = "NYC"
    @item[:start_datetime] = Time.now + 1.week
    @item.save
    @another_item = Factory.create(:item, :category_id => "event")
    @user1 = Factory.create(:user)
    comment = Factory.create(:item_comment, :user_id => @user1.id, :item_id => @item.id)
    comment.send(:update_item_comment_count)
    @review = Factory.create(:review, 
      :user_id => @user1.id, 
      :item_id => @item.id, 
      :description => "some description A", 
      :first_word_list => "first words A",
      :criteria_1 => 5.0,
      :criteria_2 => 4.0,
      :criteria_3 => 3.0,
      :created_at => Time.now
    )
  end
  
  it "should return item hypes" do
    @user2 = Factory.create(:user)
    @review = Factory.create(:review, 
      :user_id => @user2.id, 
      :item_id => @item.id, 
      :description => "some description B", 
      :first_word_list => "first words B",
      :criteria_1 => 4.0,
      :criteria_2 => 3.0,
      :criteria_3 => 2.0, 
      :created_at => Time.now - 10.days
    )
    Factory.create(:review, 
      :user_id => @user2.id, 
      :item_id => @another_item.id, 
      :description => "some description C", 
      :first_word_list => "first words C",
      :criteria_1 => 4.0,
      :criteria_2 => 3.0,
      :criteria_3 => 2.0
    )
    Factory.create(:label, :type => "pro", :tag => "Tag_A", :user_id => @user2.id, :item_id => @item.id, :review_id => @review.id)
    Factory.create(:label, :type => "con", :tag => "Tag_B", :user_id => @user2.id, :item_id => @item.id, :review_id => @review.id)
    get :index, :item_id => 1, :format => :json
    response.status.should == "200 OK"
    response.request.env['REQUEST_URI'].should == "/api/items/1/hypes.json"
    json = JSON.parse(response.body)
    json["context"]["item"]["name"].should == "Item1"
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
    json["context"]["item"]["hypes_count"].should == 2
    json["context"]["item"]["last_hyped"].should_not == nil
    json["context"]["item"]["score"].should == 3.5
    json["context"]["item"]["average_metric_ratings"].should_not == nil
    json["context"]["item"]["average_metric_ratings"][0]["metric_tag"].should == 'Quality'
    json["context"]["item"]["average_metric_ratings"][0]["rating"].should == 4.5
    json["context"]["item"]["average_metric_ratings"][1]["metric_tag"].should == 'Value'
    json["context"]["item"]["average_metric_ratings"][1]["rating"].should == 3.5
    json["context"]["item"]["average_metric_ratings"][2]["metric_tag"].should == 'Utility'
    json["context"]["item"]["average_metric_ratings"][2]["rating"].should == 2.5
    json["objects"].size.should == 2
    json["objects"][0]["hype"]["user_id"].should == @user1.id
    json["objects"][0]["hype"]["user_name"].should == "Joe1 Shmoe1"
    json["objects"][0]["hype"]["user_thumbnail_url"] = "http://test.thehypenetworks.com/images/default_male_thumb_avatar.png"
    json["objects"][0]["hype"]["created_at"].should_not == nil
    json["objects"][0]["hype"]["updated_at"].should_not == nil
    json["objects"][0]["hype"]["quality"].should == 5.0
    json["objects"][0]["hype"]["value"].should == 4.0 
    json["objects"][0]["hype"]["utility"].should == 3.0
    json["objects"][0]["hype"]["score"].should == 4.0
    json["objects"][0]["hype"]["id"].should == 1
    json["objects"][0]["hype"]["item_id"].should == 1
    json["objects"][0]["hype"]["review"].should == "some description A"
    json["objects"][0]["hype"]["first_words"] == "first words A"
    json["objects"][0]["hype"]["metric_ratings"][0]["metric_tag"].should == 'quality'
    json["objects"][0]["hype"]["metric_ratings"][0]["rating"].should == 5.0
    json["objects"][0]["hype"]["metric_ratings"][1]["metric_tag"].should == 'value'
    json["objects"][0]["hype"]["metric_ratings"][1]["rating"].should == 4.0
    json["objects"][0]["hype"]["metric_ratings"][2]["metric_tag"].should == 'utility'
    json["objects"][0]["hype"]["metric_ratings"][2]["rating"].should == 3.0
    json["objects"][0]["hype"]["pros"].should == []
    json["objects"][0]["hype"]["cons"].should == []
    
    json["objects"][1]["hype"]["user_id"].should == @user2.id
    json["objects"][1]["hype"]["user_name"].should == "Joe1 Shmoe1"
    json["objects"][1]["hype"]["user_thumbnail_url"].should == "http://test.thehypenetworks.com/images/default_male_thumb_avatar.png"
    json["objects"][1]["hype"]["created_at"].should_not == nil
    json["objects"][1]["hype"]["updated_at"].should_not == nil
    json["objects"][1]["hype"]["quality"].should == 4.0
    json["objects"][1]["hype"]["value"].should == 3.0 
    json["objects"][1]["hype"]["utility"].should == 2.0
    json["objects"][1]["hype"]["score"].should == 3.0
    json["objects"][1]["hype"]["id"].should == 2
    json["objects"][1]["hype"]["item_id"].should == 1
    json["objects"][1]["hype"]["review"].should == "some description B"
    json["objects"][1]["hype"]["first_words"] == "first words B"
    json["objects"][1]["hype"]["metric_ratings"][0]["metric_tag"].should == 'quality'
    json["objects"][1]["hype"]["metric_ratings"][0]["rating"].should == 4.0
    json["objects"][1]["hype"]["metric_ratings"][1]["metric_tag"].should == 'value'
    json["objects"][1]["hype"]["metric_ratings"][1]["rating"].should == 3.0
    json["objects"][1]["hype"]["metric_ratings"][2]["metric_tag"].should == 'utility'
    json["objects"][1]["hype"]["metric_ratings"][2]["rating"].should == 2.0
    json["objects"][1]["hype"]["pros"].size.should == 1
    json["objects"][1]["hype"]["pros"][0]["text"].should == "Tag_A"
    json["objects"][1]["hype"]["pros"][0]["hype_id"].should == @review.integer_id
    json["objects"][1]["hype"]["pros"][0]["item_id"].should == @item.integer_id
    json["objects"][1]["hype"]["cons"].size.should == 1
    json["objects"][1]["hype"]["cons"][0]["text"].should == "Tag_B"
    json["objects"][1]["hype"]["cons"][0]["hype_id"].should == @review.integer_id
    json["objects"][1]["hype"]["cons"][0]["item_id"].should == @item.integer_id
  end
  
  it "should return one hype with details" do
    Factory.create(:label, :type => "pro", :tag => "Tag_A", :user_id => @user1.id, :item_id => @item.id, :review_id => @review.id)
    Factory.create(:label, :type => "con", :tag => "Tag_B", :user_id => @user1.id, :item_id => @item.id, :review_id => @review.id)
    get :show, :item_id => 1, :id => @review.integer_id, :format => :json
    response.status.should == "200 OK"
    response.request.env['REQUEST_URI'].should == "/api/items/1/hypes/1.json"
    json = JSON.parse(response.body)
    json["context"]["item"]["name"].should == "Item1"
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
    json["context"]["item"]["hypes_count"].should == 2
    json["context"]["item"]["last_hyped"].should_not == nil
    json["context"]["item"]["score"].should == 3.5
    json["context"]["item"]["average_metric_ratings"].should_not == nil
    json["context"]["item"]["average_metric_ratings"][0]["metric_tag"].should == 'Quality'
    json["context"]["item"]["average_metric_ratings"][0]["rating"].should == 4.5
    json["context"]["item"]["average_metric_ratings"][1]["metric_tag"].should == 'Value'
    json["context"]["item"]["average_metric_ratings"][1]["rating"].should == 3.5
    json["context"]["item"]["average_metric_ratings"][2]["metric_tag"].should == 'Utility'
    json["context"]["item"]["average_metric_ratings"][2]["rating"].should == 2.5
    json["object"]["hype"]["user_thumbnail_url"].should == "http://test.thehypenetworks.com/images/default_male_thumb_avatar.png"
    json["object"]["hype"]["item_name"].should == "Item1"
    json["object"]["hype"]["created_at"].should_not == nil
    json["object"]["hype"]["updated_at"].should_not == nil
    json["object"]["hype"]["review"].should == "some description A"
    json["object"]["hype"]["first_words"].should == "first words A"
    json["object"]["hype"]["id"].should == 1
    json["object"]["hype"]["item_id"].should == @item.integer_id
    json["object"]["hype"]["score"].should == 4.0
    json["object"]["hype"]["quality"].should == 5.0
    json["object"]["hype"]["value"].should == 4.0
    json["object"]["hype"]["utility"].should == 3.0
    json["object"]["hype"]["user_id"].should == @user1.id
    json["object"]["hype"]["user_name"].should == "Joe1 Shmoe1"
    json["object"]["hype"]["user"]["created_at"].should_not == nil
    json["object"]["hype"]["user"]["updated_at"].should_not == nil
    json["object"]["hype"]["user"]["username"].should == "Joe1 Shmoe1"
    json["object"]["hype"]["user"]["first_name"].should == "Joe1"
    json["object"]["hype"]["user"]["last_name"].should == "Shmoe1"
    json["object"]["hype"]["user"]["id"].should == @user1.id
    json["object"]["hype"]["user"]["thumbnail_url"].should == "http://test.thehypenetworks.com/images/default_male_thumb_avatar.png"
    json["object"]["hype"]["user"]["hypes_count"].should == 1
    json["object"]["hype"]["user"]["shares_count"].should == nil
    json["object"]["hype"]["user"]["followers_count"].should == 0
    json["object"]["hype"]["user"]["followees_count"].should == 0
    json["object"]["hype"]["metric_ratings"][0]["metric_tag"].should == 'quality'
    json["object"]["hype"]["metric_ratings"][0]["rating"].should == 5.0
    json["object"]["hype"]["metric_ratings"][1]["metric_tag"].should == 'value'
    json["object"]["hype"]["metric_ratings"][1]["rating"].should == 4.0
    json["object"]["hype"]["metric_ratings"][2]["metric_tag"].should == 'utility'
    json["object"]["hype"]["metric_ratings"][2]["rating"].should == 3.0
    json["object"]["hype"]["pros"][0]["hype_id"].should == @review.integer_id
    json["object"]["hype"]["pros"][0]["created_at"].should_not == nil
    json["object"]["hype"]["pros"][0]["updated_at"].should_not == nil
    json["object"]["hype"]["pros"][0]["text"].should == "Tag_A"
    json["object"]["hype"]["pros"][0]["pro_id"].should == 0 # is this really needed?
    json["object"]["hype"]["pros"][0]["id"].should == 0 # is this really needed?
    json["object"]["hype"]["pros"][0]["count"].should == 1 # is this really needed?
    json["object"]["hype"]["pros"][0]["item_id"].should == @item.integer_id
    json["object"]["hype"]["cons"][0]["hype_id"].should == @review.integer_id
    json["object"]["hype"]["cons"][0]["created_at"].should_not == nil
    json["object"]["hype"]["cons"][0]["updated_at"].should_not == nil
    json["object"]["hype"]["cons"][0]["text"].should == "Tag_B"
    json["object"]["hype"]["cons"][0]["con_id"].should == 0 # is this really needed?
    json["object"]["hype"]["cons"][0]["id"].should == 0 # is this really needed?
    json["object"]["hype"]["cons"][0]["count"].should == 1 # is this really needed?
    json["object"]["hype"]["cons"][0]["item_id"].should == @item.integer_id
  end
    
  it "should create new hype with existing labels" do
    Review.destroy_all
    LabelStat.destroy_all
    Label.destroy_all
    Factory.create(:label_stat, :type => "pro", :tag => "Tag_A", :item_id => @item.id, :value => 1, :created_at => Time.now)
    Factory.create(:label_stat, :type => "pro", :tag => "Tag_B", :item_id => @item.id, :value => 1, :created_at => Time.now + 1.minute)
    Factory.create(:label_stat, :type => "pro", :tag => "Tag_C", :item_id => @item.id, :value => 1, :created_at => Time.now + 2.minutes)
    Factory.create(:label_stat, :type => "con", :tag => "Tag_D", :item_id => @item.id, :value => 1, :created_at => Time.now + 3.minutes)
    Factory.create(:label_stat, :type => "con", :tag => "Tag_E", :item_id => @item.id, :value => 1, :created_at => Time.now + 4.minutes)
    Factory.create(:label_stat, :type => "con", :tag => "Tag_F", :item_id => @item.id, :value => 1, :created_at => Time.now + 5.minutes)
    hype = {
      :user_id => @user1.id,
      :first_words => 'my first impression',
      :review => 'this is my review',
      :pro_ids => '1, 2, 3',
      :con_ids => '4, 5, 6',
      :metric_ratings_attributes => {
        :utility => '3',
        :value => '4',
        :quality => '5'
      }
    }
    post :create, :format => :json, :item_id => @item.integer_id, :hype => hype
    review = Review.first
    review.user_id.should == @user1.id
    review.first_words.should == 'my first impression'
    review.description.should == 'this is my review'
    review.criteria_1.should == 3
    review.criteria_2.should == 4
    review.criteria_3.should == 5
    review.score.should == 4.0
    review.pros[0].tag.should == "Tag_A"
    review.pros[1].tag.should == "Tag_B"
    review.pros[2].tag.should == "Tag_C"
    review.cons[0].tag.should == "Tag_D"
    review.cons[1].tag.should == "Tag_E"
    review.cons[2].tag.should == "Tag_F"
    @item.pros.should == ["Tag_A", "Tag_B", "Tag_C"]
    @item.cons.should == ["Tag_D", "Tag_E", "Tag_F"]    
  end

  it "should create new hype with some new labels" do
    Review.destroy_all
    LabelStat.destroy_all
    Label.destroy_all
    Factory.create(:label_stat, :type => "pro", :tag => "Tag_A", :item_id => @item.id, :value => 1, :created_at => Time.now)
    Factory.create(:label_stat, :type => "con", :tag => "Tag_D", :item_id => @item.id, :value => 1, :created_at => Time.now + 1.minute)
    hype = {
      :user_id => @user1.id,
      :first_words => 'my first impression',
      :review => 'this is my review',
      :pro_ids => '1',
      :con_ids => '2',
      :metric_ratings_attributes => {
        :utility => '3',
        :value => '4',
        :quality => '5'
      },
      :pros_attributes => {
        "1"=>{
          "text"=>"Tag_B", 
          "item_id"=>"#{@item.integer_id}"
        }, 
        "2"=>{
          "text"=>"Tag_C", 
          "item_id"=>"#{@item.integer_id}"
        }
      },
      :cons_attributes => {
        "3"=>{
          "text"=>"Tag_E", 
          "item_id"=>"#{@item.integer_id}"
        }, 
        "4"=>{
          "text"=>"Tag_F", 
          "item_id"=>"#{@item.integer_id}"
        }
      }
    }
    post :create, :format => :json, :item_id => @item.integer_id, :hype => hype
    review = Review.first
    review.user_id.should == @user1.id
    review.item_id.should == @item.id
    review.first_words.should == 'my first impression'
    review.description.should == 'this is my review'
    review.criteria_1.should == 3
    review.criteria_2.should == 4
    review.criteria_3.should == 5
    review.score.should == 4.0
    review.pros[0].tag.should == "Tag_A"
    review.pros[1].tag.should == "Tag_B"
    review.pros[2].tag.should == "Tag_C"
    review.cons[0].tag.should == "Tag_D"
    review.cons[1].tag.should == "Tag_E"
    review.cons[2].tag.should == "Tag_F"
    @item.pros.should == ["Tag_A", "Tag_B", "Tag_C"]
    @item.cons.should == ["Tag_D", "Tag_E", "Tag_F"]    
  end
end





