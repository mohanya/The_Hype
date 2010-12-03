require 'spec_helper'

FakeWeb.allow_net_connect = true

describe Api::FavoritesController do
  integrate_views
  
  it "should create new favorite" do
    ItemFavorite.count.should == 0
    Item.any_instance.stubs(:reindex_sunspot).returns(true)
    Factory.create(:item_category, :name => "event", :api_source => "event")
    @item = Factory.create(:item, :category_id => "event", :name => "Test Item")
    @user = Factory.create(:user)
    favorite = {
      "user_id" => "#{@user.id}"
    }
    post :create, :item_id => 1, :format => :json, :favorite => favorite
    json = JSON.parse(response.body)
    json["success"].should == true
    #json["id"].should == 1 # is it really needed?
    ItemFavorite.count.should == 1
    fav = ItemFavorite.first
    fav.item_id.should == @item.id
    fav.user_id.should == @user.id
    fav.item_category_id.should == "event"
    fav.favorite.should == true
  end

end