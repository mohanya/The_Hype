require File.dirname(__FILE__) + '/../spec_helper'

describe Activity do
  
  it "should return an array with name of 'jim' and comments" do
    review = Review.make(:comments => 'This was cool' )
    user = review.user
    stream = Activity.get_stream
    stream_description = "Hyped <a href='/items/" + review.item.id + "'>" + review.item.name + "</a>"
    stream.map {|s| s.user}.should include(user) 
    stream.map {|s| s[:description]}.should include(stream_description) 
  end
  
  it "should include comments" do
    comment = ItemComment.make(:comment_text => "Item Comment")
    user = comment.user
    stream = Activity.get_stream
    stream_comment = "Commented on <a href='/items/" + comment.item.id + "'>Realbridge</a>"
    
    stream.map {|s| s[:description]}.should include(stream_comment) 
  end
  
  it "should add a new favorite" do
    favorite = ItemFavorite.make(:favorite => true)
    user = favorite.user
    stream = Activity.get_stream
    stream_favorite = "Favorited <a href='/items/" + favorite.item.id + "'>#{favorite.item.name}</a>"
    
    stream.map {|s| s[:description]}.should include(stream_favorite) 
  end
  
  it "should add an unfavorite" do
    favorite = ItemFavorite.make(:favorite => true)
    user = favorite.user
    #calling set_favorite will set the favorite to false
    user.set_favorite(favorite.item_id)
    stream = Activity.get_stream
    stream_favorite = "Unfavorited <a href='/items/" + favorite.item.id + "'>#{favorite.item.name}</a>"
    
    stream.map {|s| s[:description]}.should include(stream_favorite) 
  end
  
  it "should be sorted by activity_date desc which is based on updated_at" do
    pending
    Review.make(:comments => "New Review", :updated_at => 1.minute.ago)
    ItemComment.make(:comment_text => "Old Comment", :updated_at => 1.month.ago)
    ItemComment.make(:comment_text => "New Comment", :updated_at => 1.minute.ago)
    item = Item.make(:name => "bon jovie", :updated_at => Time.now)
    stream_description = "Added <a href='/items/" + item.id + "'>" + item.name + "</a>"
    
    stream = Activity.get_stream
    
    stream.first[:description].should == stream_description
  end
  
  
end
