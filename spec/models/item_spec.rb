require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Item do


  #it "should create valid item" do
  #  item = Item.make
  #  item.should be_valid
  #  item.save.should == true
  #end
  #
  #it "should require name" do
  #  item = Item.make_unsaved(:name => nil)
  #  item.should_not be_valid
  #  item.save.should == false
  #end
  #
  #it "should return correct search results from internal items" do
  #  Item.make(:name => "iphone 3g")
  #  Item.make(:name => "iphone 3gs")
  #  Item.make(:name => "blackberry storm")
  #  
  #  Item.search("iphone").map(&:name).should == ["iphone 3g", "iphone 3gs"]
  #end
  #
  #it "should return correct search results from shopping.com api" do
  #  stub_get("http://sandbox.api.shopping.com/publisher/3.0/rest/GeneralSearch?pageNumber=1&numItems=10&apiKey=authorized-key&trackingId=7000610&keyword=nikon", "shopping_general_search.xml")
  #  
  #  Item.search_shopping_api("nikon").map(&:name).should include("Nikon D5000 Body Only Digital Camera")
  #end
  #
  #it "should return correct search results on page 2 of shopping api" do
  #  stub_get("http://sandbox.api.shopping.com/publisher/3.0/rest/GeneralSearch?pageNumber=2&numItems=10&apiKey=authorized-key&trackingId=7000610&keyword=nikon", "shopping_general_search_page_2.xml")

  #  Item.search_shopping_api("nikon", {:page => 2}).map(&:name).should include("Nikon D90 Digital Camera with 18-105mm lens")
  #end
  #
  #it "should return internal results only on search" do
  #  Item.make(:name => "Nikon CoolPix 007")
  #  stub_get("http://sandbox.api.shopping.com/publisher/3.0/rest/GeneralSearch?pageNumber=1&numItems=10&apiKey=authorized-key&trackingId=7000610&keyword=nikon", "shopping_general_search.xml")
  #  
  #  # page 1 will only return internal data
  #  Item.search("nikon", {:page => 1}).map(&:name).should include("Nikon CoolPix 007")
  #  Item.search("nikon", {:page => 2}).map(&:name).should_not include("Nikon D90 Digital Camera with 18-105mm lens")
  #end
  #
  #it "should not return product from api if it already exists in the database" do
  #  Item.make(:name => "Nikon D5000 Body Only Digital Camera", :source_id => "84682579")
  #  stub_get("http://sandbox.api.shopping.com/publisher/3.0/rest/GeneralSearch?pageNumber=1&numItems=10&apiKey=authorized-key&trackingId=7000610&keyword=nikon", "shopping_general_search.xml")
  #  
  #  item = Item.first(:source_id => "84682579")
  #  # page 2 will return api data without the product in DB
  #  Item.search("nikon", {:page => 2}).map{|i| i.source_id}.should_not include(item.source_id)
  #end
  #
  #
  #it "should calculate score" do
  #  item = Item.make
  #
  #  item.reviews << Review.make(:criteria_1 => 2, :criteria_2 => 3, :criteria_3 => 4)
  #  item.reviews << Review.make(:criteria_1 => 2, :criteria_2 => 3, :criteria_3 => 4)
  #  item.reviews << Review.make(:criteria_1 => 2, :criteria_2 => 3, :criteria_3 => 4)
  #
  #  item.score.should == 0
  #  item.calculate_score
  #  item.score.should == ((2.0 + 3.0 + 4.0) / 3).to_f
  #end
  #
  #it "should calculate hype worth" do
  #  item = Item.make(:name => "new product")

  #  item.reviews << Review.make(:recommended => true)
  #  item.reviews << Review.make(:recommended => true)
  #  item.reviews << Review.make(:recommended => true)
  #  item.reviews << Review.make(:recommended => false)

  #  item.hype_worth.should be_nil
  #  item.calculate_hype_worth
  #  item.hype_worth.should == 75
  #end
  #
  #it "should get spec data from the Shopping api" do
  #  stub_get("http://sandbox.api.shopping.com/publisher/3.0/rest/GeneralSearch?trackingId=7000610&productId=45016720&showProductSpecs=true&apiKey=authorized-key", "shopping_product.xml")
  #  
  #  ic = ItemCategory.make(:name => 'Products', :api_source => "product")     
  #  item = Item.make_unsaved(:name => "Apple iPhone (8 GB) Smartphone", :source_id => 45016720, :category => ic)
  #  item.get_data_from_api
  #  #item.item_details.size.should > 0
  #  item.source_url.should != nil
  #end
  #
  #it "should search for artist from the Last.fm api" do
  #      stub_get("http://ws.audioscrobbler.com/2.0/?artist=Metallica&api_key=3264b20f033ca143aa6d13d08a2ad0f2&method=artist.search&limit=5&page=1", "artist/search.xml")
  #  stub_get("http://ws.audioscrobbler.com/2.0/?artist=Metallica&api_key=3264b20f033ca143aa6d13d08a2ad0f2&method=artist.getinfo", "artist/info.xml")
  #  
  #  ic = ItemCategory.make(:api_source => "music-artist")     
  #  items = Item.search_external_api("Metallica", ic.api_source)
  #  items.first.name.should == "Metallica"
  #end
  #
  #it "should search for move from the themoviedb.org api" do
  #  stub_get("http://api.themoviedb.org/2.1/Movie.search/en/json/c29a0b0be0891bdf0ae3aef6d2613c18/Transformers", "movie/search.json")
  #  
  #  ic = ItemCategory.make(:api_source => "movie")     
  #  items = Item.search_external_api("Transformers", ic.api_source)
  #  items.first.name.should == "Transformers"
  #  items.first.released.year.should == 2007
  #end
  #
  #it "should save twitter trends" do
  #  item = Item.make(:name => "iphone 3gs", :twitter_query => "iphone 3g")
  #  stub_get("http://search.twitter.com/search.json?rpp=100&q=iphone%203g%20since%3A2009-11-24%20until%3A2009-11-24", "twitter_search_iphone3gs.json")
  #  item.fetch_twitter_trends(item.twitter_query, "Tue, 24 Nov 2009".to_time)
  #  item.trends.first.mention_count == 100
  #end
  #
  #it "should have a pros list of fast (2) and sleek(1)" do
  #  pending
  #  i = Item.make
  #  Review.make(:item_id => i.id, :pros => ["fast", "sleek"])
  #  Review.make(:item_id => i.id, :pros => ["fast"])
  #  item = Item.find(i.id)
  #  item.pro_counts.select{|k,v| k == "fast"}.flatten[1].should == 2
  #  item.pro_counts.select{|k,v| k == "sleek"}.flatten[1].should == 1
  #end
  #
  #it "should have a pros list where the top pro count is first in the hash" do
  #  pending
  #  i = Item.make
  #  Review.make(:item_id => i.id, :pros => ["price", "fast", "sleek"])
  #  Review.make(:item_id => i.id, :pros => ["fast", "sleek"])
  #  Review.make(:item_id => i.id, :pros => ["fast"])
  #  item = Item.find(i.id)
  #  item.pro_counts.map{|k,v| [k]}.flatten.should == ["fast", "sleek", "price"]
  #end
  #
  #it "should have a sum of the pro counts of 5" do
  #  pending
  #  i = Item.make
  #  Review.make(:item_id => i.id, :pros => ["price", "fast", "sleek"])
  #  Review.make(:item_id => i.id, :pros => ["fast", "sleek"])
  #  item = Item.find(i.id)
  #  item.sum_pro_counts.should == 5
  #end

  #it "should have a cons list of slow(2) and price(1)" do
  #  pending
  #  i = Item.make
  #  Review.make(:item_id => i.id, :cons => ["slow", "price"])
  #  Review.make(:item_id => i.id, :cons => ["slow"])
  #  item = Item.find(i.id)
  #  item.con_counts.select{|k,v| k == "slow"}.flatten[1].should == 2
  #  item.con_counts.select{|k,v| k == "price"}.flatten[1].should == 1
  #end
  #
  #it "should have a cons list where the top con count is first in the hash" do
  #  pending
  #  i = Item.make
  #  Review.make(:item_id => i.id, :cons => ["price", "slow", "support"])
  #  Review.make(:item_id => i.id, :cons => ["price", "support"])
  #  Review.make(:item_id => i.id, :cons => ["support"])
  #  item = Item.find(i.id)
  #  item.con_counts.map{|k,v| [k]}.flatten.should == ["support", "price", "slow"]
  #end
  #
  #it "should have a sum of the con counts of 4" do
  #  pending
  #  i = Item.make
  #  Review.make(:item_id => i.id, :cons => ["price", "slow", "support"])
  #  Review.make(:item_id => i.id, :cons => ["price"])
  #  item = Item.find(i.id)
  #  item.sum_con_counts.should == 4
  #end
  #
  #it "should have a most hyped in the correct order" do
  #  i1 = Item.make(:name => "hype1")
  #  i2 = Item.make(:name => "hype2")
  #  
  #  Review.make(:item_id => i1.id)
  #  Review.make(:item_id => i1.id)
  #  Review.make(:item_id => i1.id)
  #  Review.make(:item_id => i1.id)
  #  Review.make(:item_id => i2.id)
  #  
  #  items = Item.most_hyped
  #  items.first.name.should == "hype1"
  #end
  #
  #it "should have a most active conversations in the correct order" do
  #  i1 = Item.make(:name => "commented item 1")
  #  i2 = Item.make(:name => "commented item 2")
  #  
  #  ItemComment.make(:item_id => i1.id)
  #  ItemComment.make(:item_id => i1.id)
  #  ItemComment.make(:item_id => i1.id)
  #  ItemComment.make(:item_id => i1.id)
  #  ItemComment.make(:item_id => i2.id)    
  #  
  #  items = Item.most_commented
  #  
  #  items.first.name.should == "commented item 1"
  #end
  #
  #it "should limit most active conversations" do
  #  i1 = Item.make()
  #  i2 = Item.make()
  #  i3 = Item.make()
  #  i4 = Item.make()
  #  
  #  ItemComment.make(:item_id => i1.id)
  #  ItemComment.make(:item_id => i2.id)
  #  ItemComment.make(:item_id => i3.id)
  #  ItemComment.make(:item_id => i4.id)
  #  ItemComment.make(:item_id => i4.id)    
  #  
  #  Item.most_commented(3).size.should == 3
  #end
  #
  #it "should save a default category tag" do
  #  pending
  #  ic = ItemCategory.make(:name => "Product", :tag_name => "product")
  #  i = Item.make()
  #  i.category = ic
  #  i.save
  #  i.reload
  #  i.tags.should include(ic.tag_name)
  #end
  #  
  #it "should add a default category tag" do
  #  pending
  #  ic = ItemCategory.make(:name => "Product", :tag_name => "product")
  #  i = Item.make(:tags => ['cool', 'pricey'])
  #  i.category = ic
  #  i.save
  #  i.reload
  #  i.tags.should include(ic.tag_name)
  #  i.tags.should include('cool')
  #end
  
end
