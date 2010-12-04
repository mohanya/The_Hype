require 'spec_helper'

FakeWeb.allow_net_connect = true

describe Api::LabelStatsController do
  integrate_views
  
  before(:all) do
    LabelStat.destroy_all
    Item.any_instance.stubs(:reindex_sunspot).returns(true)
    @category = Factory.create(:item_category, :name => "event", :api_source => "event")
    @item = Factory.create(:item, :category_id => "event")
    @item[:address] = "NYC"
    @item[:start_datetime] = Time.now + 1.week
    @item.save
    Factory.create(:label_stat, :type => "pro", :tag => "Tag_A", :item_id => @item.id, :value => 10, :created_at => Time.now)
    Factory.create(:label_stat, :type => "pro", :tag => "Tag_B", :item_id => @item.id, :value => 5, :created_at => Time.now + 1.minute)
    Factory.create(:label_stat, :type => "con", :tag => "Tag_C", :item_id => @item.id, :value => 10, :created_at => Time.now + 2.minutes)
    Factory.create(:label_stat, :type => "con", :tag => "Tag_D", :item_id => @item.id, :value => 5, :created_at => Time.now + 3.minutes)
  end

  it "should return list of pros while creating new hype" do
    get :index, :item_id => @item.integer_id, :format => :json, :pro => "1"
    response.request.env['REQUEST_URI'].should == "/api/items/1/pros.json"
    json = JSON.parse(response.body)
    json["objects"].size.should == 2
    #json["objects"][0]["pro"]["created_at"].should_not == nil # needed?
    #json["objects"][0]["pro"]["updated_at"].should_not == nil # needed?
    json["objects"][0]["pro"]["id"].should == 1
    json["objects"][0]["pro"]["item_id"].should == @item.integer_id
    json["objects"][0]["pro"]["text"].should == "Tag_A"
    json["objects"][0]["pro"]["count"].should == 10
    json["objects"][1]["pro"]["id"].should == 2
    json["objects"][1]["pro"]["item_id"].should == @item.integer_id
    json["objects"][1]["pro"]["text"].should == "Tag_B"
    json["objects"][1]["pro"]["count"].should == 5
  end

  it "should return list of cons while creating new hype" do
    get :index, :item_id => @item.integer_id, :format => :json, :con => "1"
    response.request.env['REQUEST_URI'].should == "/api/items/1/cons.json"
    json = JSON.parse(response.body)
    json["objects"].size.should == 2
    json["objects"][0]["con"]["id"].should == 3
    json["objects"][0]["con"]["item_id"].should == @item.integer_id
    json["objects"][0]["con"]["text"].should == "Tag_C"
    json["objects"][0]["con"]["count"].should == 10
    json["objects"][1]["con"]["id"].should == 4
    json["objects"][1]["con"]["item_id"].should == @item.integer_id
    json["objects"][1]["con"]["text"].should == "Tag_D"
    json["objects"][1]["con"]["count"].should == 5
  end
end