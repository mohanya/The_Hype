require 'gluestick'
# Please remember to avoid loading whole item if it's not neccessary
# Always try to use :select => 'id, and, whatever, you, need'.
class Item
  CUSTOM_ITEM_LENGTH = 4
  include MongoMapper::Document
  plugin MongoMapper::Plugins::Associations::NestedAttributes
  
  include FriendlyUniqueId
  
  # this is so we can format wikipedia content into html and then store it in html format.
  include WikiCloth
  
  # iPhone API
  include CustomJsonSerializer
  include ApplicationHelper
  include IphoneApiMethods
  
  has_friendly_unique_id :name
  
  many :reviews, :dependent => :destroy
  many :tips, :dependent => :destroy
  many :item_details, :dependent => :destroy
  many :labels, :dependent => :destroy
  many :trends, :dependent => :destroy
  many :comments, :class_name => "ItemComment", :dependent => :destroy
  many :medias, :class_name => "ItemMedia", :dependent => :destroy
  many :activities, :polymorphic => true, :foreign_key => :source_id_string, :dependent => :destroy
  many :tops, :class_name => "UserTop", :dependent => :destroy
  accepts_nested_attributes_for :medias
  
  belongs_to :category, :class_name => "ItemCategory",  :foreign_key => :category_id
  
  
  key :_id, String 
  key :name, String, :required => true
  key :short_description, String
  #key :full_description, String
  key :user_id, Integer
  key :url, String
  key :custom_item, String
  key :custom_url, String
  key :item_url, String
  # Declaring category_id so it exists in our default_category_tag before_save call that accesses item.category
  key :category_id, String
  
  # Store information from API source if item is coming from an API
  key :source_id, String
  key :source_name, String
    
  key :criteria_1, Float, :default => 0.0
  key :criteria_2, Float, :default => 0.0
  key :criteria_3, Float, :default => 0.0
  key :score, Float, :default => 0.0
  #-----------------just using item media, primary => true now
  #Using image_url for temporary items from api's
  key :basic_image_url, String
  # key :image_height, Integer
  # key :image_width, Integer
  key :hype_worth, Integer
  key :twitter_query, String
  key :facebook_query, String
  
  key :review_count, Integer
  key :comment_count, Integer
  
  # tags is being replaced
  # key :tags, Array
  
#  key :details, Hash
  key :_type, String

  key :artist_name
  
  key :search_terms, String
  key :unfinished_images, Boolean, :default => false
  
  # iPhone API
  key :integer_id, Integer
  
  timestamps!
  
  after_create lambda { |item| Activity.delay.record(item.id, 'Item') }
  after_create :get_trends
  
  before_create :save_artist_info
  before_create :add_integer_id
  before_save :extract_search_terms
  
  after_update :delete_cache
  after_save :reindex_sunspot

  before_destroy :delete_cache
  before_destroy :remove_sunspot
  
  attr_accessor :root_category


    
  def score_color(reviews=nil)
    score = self.friendly_score(reviews)
    case
      when score < 2.6 then "red"
      when (score > 2.5 and score < 4) then "yellow"
      when score > 3.9 then "blue"
    end
  end

  #using only datetime returns stupid things when user dont selet time or date
  def correct_times
     if start_datetime and start_time and !start_datetime.blank?  and !start_time.blank?
        start = start_datetime.strftime("%A %B, %e %Y %I:%M %p")
     elsif start_datetime and !start_datetime.blank?
        start = start_datetime.strftime("%A %B, %e %Y")
     else 
        start = start_time
     end
     if end_datetime and end_time and !end_datetime.blank? and !end_time.blank?
        finish = end_datetime.strftime("%A %B, %e %Y %I:%M %p")
     elsif  end_datetime and !end_datetime.blank?
        finish = end_datetime.strftime("%A %B, %e %Y")
     else 
        finish = end_time
     end
     return start, finish
  end
    
  def user
    user_id.blank? ? nil : User.find(user_id)
  end

  def fix_coding(c)
    c.strip!
    c.gsub!(/\342\200(?:\234|\235)/,'"')
    c.gsub!(/\342\200(?:\230|\231)/,"'")
    c.gsub!(/\342\200\223/,"-")
    c.gsub!(/\342\200\246/,"...")
    c.gsub!(/\303\242\342\202\254\342\204\242/,"'")
    c.gsub!(/\303\242\342\202\254\302\235/,'"')
    c.gsub!(/\303\242\342\202\254\305\223/,'"')
    c.gsub!(/\303\242\342\202\254"/,'-')
    c.gsub!(/\342\202\254\313\234/,'"')
    return c
  end
   
  # Category list that will map to inherited model classes use to capture and access data
  def self.category_list
    %w(product event)
  end
  
  def positive_trends
    # trends.select {|t| t.mention_count and t.mention_count > 0}
    trends.all(:order=>"query_date ASC").group_by {|t| t.query_date}.map do |query_date, trend| 
      [query_date, trend.map{|t| t.mention_velocity}.sum]
    end

  end

  def get_trends
   Item.delay.get_twitter_trends(self.id)
 end

 # it's better to only save id in delayed jobs - saving whole item takes way much space
 def self.get_twitter_trends(id)
   Item.find(id).fetch_all_trends('twitter')
  end
  
  def cached_fetch_all_trends
    begin
      Rails.cache.fetch("twitter_trends_#{self.id}", :expires_in => 6.hours) { self.fetch_all_trends('twitter', self.twitter_query, true) }
      Rails.cache.fetch("facebook_trends_#{self.id}", :expires_in => 6.hours) { self.fetch_all_trends('facebook', self.twitter_query, true) }
    rescue
      self.fetch_all_trends('twitter', self.twitter_query, true)
      self.fetch_all_trends('facebook', self.twitter_query, true)
    end
  end
    
  # Wrapper for fetch_trends to fetch for trends over the past 7 days  
  def fetch_all_trends(source, query = self.twitter_query, fetch_all=false)
    query = self.name if query.blank?
    
    default_max_date = 7.days.ago.to_date
    if fetch_all
      max_date = default_max_date
    else
      # Get the last trend date
      max_trend_date = get_max_trend_date(source)

      # If a max trend date exists and it is greater than the default max date, use that date to fetch from
      if max_trend_date and max_trend_date > default_max_date
        max_date = max_trend_date
      else
        max_date = default_max_date
      end
    
    end
    
    max_date.upto(Time.now.to_date) do |query_date|
      if query_date 
        fetch_trends(source, query, query_date.to_datetime.utc)
      end
    end    
  end
  
  def get_max_trend_date(source)
    if !self.trends.empty? and source_trends = self.trends.select{|t| t.source == source}
      source_trends.compact.map{|tt| tt.query_date}.max.to_datetime.utc rescue nil
    else
      nil
    end
  end
  
  def fetch_trends(source, query = self.twitter_query, query_date = 1.day.ago.utc)
    query = self.name if query.blank?
    
    # Get the trend if it already exists for the query_date
    existing_trend = self.trends.select{|t| t.query_date == query_date.to_date && t.source == source}.first
    
    # trend = existing_trend || self.trends.build(:query_date=>query_date)
    trend = existing_trend || Trend.new(:query_date=>query_date, :source => source)
    updated_trend = trend.velocity(query, query_date)
    
    # Always do the following unless the trend already exists and the updated mention count equals 0
    if existing_trend.nil? and updated_trend
      updated_trend.item_id = self.id
      updated_trend.save
    end   
  end

  def item_image
    primary_image || "/images/app/icon_hype_large.png"
  end
  
  def primary_image
    media = ItemMedia.first(:primary => true, :item_id => self.id)
    media ? media.image_url(:thumb) : nil
  end

  def large_primary_image
    media = ItemMedia.first(:primary => true, :item_id => self.id)
    media ? media.image_url(:large) :  "/images/app/icon_hype_large.png"
  end

  #reviews are empty when filter is set to everyone
  def friendly_score(reviews=[])
    if !reviews 
       return score.round(1)
    elsif reviews.empty?
       return 0.0
    else
      score = reviews.sum{ |x| x.score} 
      return score = (score/reviews.size).round(1)
    end
  end

  #reviews are empty when filter is set to everyone
  def friendly_criteria(reviews=[])
    if !reviews 
       return criteria_1.to_i.to_s, criteria_2.to_i.to_s, criteria_3.to_i.to_s
    elsif reviews.empty?
        return 0, 0, 0
    else
       size = reviews.size
       c1 = reviews.sum{ |x| x.criteria_1}
       c2 = reviews.sum{ |x| x.criteria_2}
       c2 = reviews.sum{ |x| x.criteria_3}
       return (c1/size).to_i.to_s, (c2/size).to_i.to_s, (c2/size).to_i.to_s
    end
  end
  
  # fits
  # 160x160
  def thumb_image
    media = ItemMedia.first(:primary => true, :item_id => self.id)
    media ? media.image_url(:thumb) : "/images/app/icon_hype_large.png"
  end

  # fits
  # 70x70
  def tiny_image
    media = ItemMedia.first(:primary => true, :item_id => self.id)
    media ? media.image_url(:tiny_thumb) : "/images/app/icon_hype_large.png"
  end
  
  # has many
  def item_media
    return ItemMedia.first(:primary => true, :item_id => self.id)
  end
  
  def last_hyped_at
    review = Review.first(:select=>[:created_at], :conditions=>{:item_id => self.id}, :order=>"created_at desc")
    review.nil? ? nil : review.created_at
  end
  
  ######################################
  # This calculates Average of all reviews and  stuff that changes after hype is added
  ######################################  
  def calculate_all_scores
    c1 = calculate_review_average(:criteria_1)
    c2 = calculate_review_average(:criteria_2)
    c3 = calculate_review_average(:criteria_3)
    score = ((c1 + c2 + c3)/3).to_f
    recommended_count = Review.count(:item_id=>self.id, :recommended=>true)
    hype_worth = (( recommended_count.to_f / reviews.count.to_f ) * 100.to_f).to_i rescue 0
    #no idea why simple item.update_attributes is no longer working.
    Item.find(self.id).update_attributes(:criteria_1 => c1, :criteria_2 => c2, :criteria_3 => c3, 
      :score => score, :hype_worth => hype_worth, :review_count => Review.count(:item_id => self.id))
  end
  
  def calculate_review_average(criteria_name)
    reviews.empty? ? 0 : reviews.map {|ir| ir.send(criteria_name)}.average
  end
  
  def calculate_hype_worth
    recommended_count = Review.count(:item_id=>self.id, :recommended=>true)
    self.update_attributes(:hype_worth => (( recommended_count.to_f / reviews.count.to_f ) * 100.to_f).to_i)
  end

  # => i.e. [{"tag"=>"Test1", "count"=>2.0, "type"=>nil}, {"tag"=>"test2", "count"=>2.0, "type"=>nil}, {"tag"=>"test3", "count"=>2.0, "type"=>nil}]
  def tag_cloud(ids= false)
    options = {:item_id => self.id, :type=>nil}
    options.merge!('user_id' => {'$in' => ids}) if ids
    labels = Label.collection.group(['tag'], options, {'count' => 0}, "function(doc, prev) {prev.count += 1; prev.type}")
  end

  def best_comments(ids = false)
    options = {:parent_id => nil}
    options.merge!(:user_id => {'$in' => ids}) if ids
    self.comments.all(options).collect{|x| [x, x.children.size]}.sort{|a, b| a[1] <=> b[1]}.reverse[0..1].map{|x| x[0]}
  end

  def self.search_by_tags(query, options = {})
    Label.all(:tag => query).map{|l| l.item}
  end

  def pros
    pro_labels = Label.all(:item_id => self.id, :type => 'pro')
    pro_labels.map{|p| p.tag}.flatten.uniq
  end

  def pro_counts(ids)
    options = {:item_id => self.id, :type => 'pro'}
    options.merge!(:user_id => {'$in' => ids}) if ids
    pro_labels = Label.all(options)
    pro_labels.map{|r| r.tag}.flatten.group_by{|p| p}.map {|a,b| [a, b.size]}.sort{|a, b| a[1] <=> b[1]}.reverse
  end


  def cons
    con_labels = Label.all(:item_id => self.id, :type => 'con')
    con_labels.map{|p| p.tag}.flatten.uniq
  end

  
  def con_counts(ids)
    options = {:item_id => self.id, :type => 'con'}
    options.merge!(:user_id => {'$in' => ids}) if ids
    con_labels = Label.all(options)
    con_labels.map{|r| r.tag}.flatten.group_by{|p| p}.map {|a,b| [a, b.size]}.sort{|a, b| a[1] <=> b[1]}.reverse
  end
  
  # Get the total number of counts for a certain type
  def sum_label_counts(type=false, ids = false)
    options = {:item_id => self.id}
    options.merge!(:type => type) if type
    options.merge!(:user_id => {'$in' => ids}) if ids
    
    count_array = self.labels.collection.group(['item_id'], options, {'count' => 0}, "function(doc, prev) {prev.count += 1;}")
		#~ count_array = []
    if count_array.length > 0
      #~ return count_array.first['count']
      #~ result = count_array.first['count'].scan(/.*](\d)/)
      result = count_array.first['count'].to_s.split('.')
			return (result.empty?)? 0 : result.flatten.first.to_f
    else
      
      return 0
    end
  end
  
  def first_word_list
    reviews.map{|r| r.first_word_list}.join(", ")
  end

  def joined_tags(tags)
    tags.collect {|tagging| tagging.tag.name }.join(", ")
  end

  # Default the category tag to the items tag list on save
  def default_category_tag
    if self.category
      self.tags = self.tags | [self.category.tag_name] 
    end
  end

  def get_data_from_api
    if source_id
      if self.source_id =~ /^glue/
        # XXX not much we can do without unique ids from the api
        self.source_name = "getglue.com"
        return
      end
      
      case category.api_source
        when "product" : pull_product_data
        when "music-artist" : pull_music_artist_data
        when "music-album" : pull_music_album_data
        when "music-track" : pull_music_track_data    
        when "movie" : pull_movie_data   
        when "event" : pull_event_data
        when "web" : pull_web_data    
      end
    end
  end

  def set_source_to_wikipedia
    self.source_name = 'wikipedia.org'
  end
  
  def pull_web_data
     set_source_to_wikipedia
  end
  
  def pull_product_data
    begin
    shopping_client ||= Shoppr::Client.new(true)
    product = shopping_client.search(:product_id=>self.source_id, :show_product_specs=>true).categories.first.products.first 
    self.source_name = "shopping.com"
    self.source_url = product.product_offers_url

    product.specifications.each do |spec|      
      features = {}
      spec.features.each do |feature|
        # We have to add this Iconv conversion due to some data from the API not being valid UTF-8 format
        # which is throwing an error when trying to save to MongoDB.
        feature_values = Iconv.conv('UTF-8//IGNORE', 'UTF-8', feature.values.join(", "))
        features[feature.name] = feature_values
      end
  
      # If the spec does not already exist, add it to the item_details
      if item_details.select{|id| id[:feature_group] == spec.name}.empty?
        self.item_details << ItemDetail.new(:feature_group => spec.name, :features => features) 
      end
    end
    rescue
    end
  end
  
  def pull_music_artist_data
    self.source_name = 'last.fm'
  end
  
  def pull_music_album_data
    self.source_name = 'last.fm'
  end
  
  def pull_music_track_data
    self.source_name = 'last.fm'
  end  

  
  def pull_movie_data
    movie =  @@tmdb.get_info(source_id) rescue nil
    if !movie  || movie.attributes == "Nothing found." 
      nice_source_id = fix_coding(name)
      all = @@tmdb.search(nice_source_id)
      unless all.empty?
         movie = all.detect{|m| m.name == nice_source_id || m.attributes["alternative_name"] == nice_source_id}
         movie =  @@tmdb.imdb_lookup(movie.imdb_id) if movie
      end
    end
    if movie and movie.attributes and movie.attributes != "Nothing found."
      self[:cast] = movie.cast.collect{|member| Hashie::Mash.new(member.attributes)}
      director = movie.cast.find {|c| c.job == "Director"} if movie.cast
      self[:director] =  director.name if director
      self[:released] = movie.released.to_time
      self[:budget] = movie.attributes["budget"]
      self[:revenue] = movie.attributes["revenue"]
      self[:runtime] = movie.runtime
      self[:url] = movie.homepage 
      self[:source_name]="themoviedb.org"
    end
  end
  
  def pull_event_data
    if (s = Upcoming::Event.info(source_id)) and (event = s.first)
      self[:venue_name] = event.venue_name
      self[:address] = event.venue_address
      self[:city] = event.venue_city
      self[:state] = event.venue_state_name
      self[:country] = event.venue_country
      self[:zip] = event.venue_zip
      self[:start_datetime] = event.utc_start.to_time if event.utc_start
      self[:end_datetime] = event.utc_end.to_time if  event.utc_end
      self[:start_time] = event.utc_start.to_time.strftime('%H:%M %Z') rescue nil
      self[:end_time] = event.utc_end.to_time.strftime('%H:%M %Z') rescue nil
      self[:ticket_price] = event.ticket_price
      self[:ticket_url] = event.ticket_url
      self[:website_url] = event.url
    end
  end
  
  # updates for extra data
  # will overwrite defaults if any of the additional info shares a key.
  def set_additional_data(item_data = {})
    self.update_attributes(item_data)
  end
  
  def movie_cast
    items = []
    count = 0
    
    if self.cast
      for person in self.cast
        if person.job == 'Actor' || person.job == 'Director'
          count = count + 1
          if person.profile == ''
            person.profile = 'default_male_xlarge_avatar.png'
          end
          items << Item.new(:name => person.name, :basic_image_url => person.profile.gsub("thumb", "profile"))
        end
        
        return items if count == 7
      end
    end
    # this is in case of the remote possibility that the movie has less then 7 people involved
    return items
  end
  
  #################################################################################
  # Music API Methods
  #################################################################################
  
  def artist
    #~ cat_id = ItemCategory.find_by_api_source("music-artist").id
    #~ Item.first(:name => /#{artist_name}/i, :category_id => cat_id)
    cat = ItemCategory.find_by_api_source("music-artist")
    if cat
      cat_id=cat.id
      Item.first(:name => /#{artist_name}/i, :category_id => cat_id)
    end
  end
  
  # Get similar artist info from Last.fm
  # TODO -- Cache this!
  def similar_artists
    items = []
    unless source_id.blank?
      artists=Scrobbler::Artist.new(source_id).similar[0..4]
      
      cat_id = ItemCategory.find_by_api_source("music-artist").id
      
      items = []
      artists.each do |artist|
        if item = Item.find_by_source_id(/#{artist.name}/i, :conditions=>{:category_id => cat_id})
          items << item
        else
          items << Item.new(:name => artist.name, :basic_image_url => artist.image_large)
        end
      end
    end 
    return items
  end
  
  # Get top album info from Last.fm
  # TODO -- Cache this!
  def top_albums
    items = []
    unless source_id.blank?
     albums=Scrobbler::Artist.new(source_id).top_albums[0..4]
     
     cat = ItemCategory.find_by_api_source("music-album")
     return [] if cat.blank?
     cat_id = cat.id
     
     albums.each do |album|
       if item = Item.find_by_source_id(/#{album.name}/i, :conditions=>{:category_id => cat_id})
         items << item
       else
         album.load_info
         items << Item.new(:name => album.name, :basic_image_url => album.image_large)
       end
     end
    end
    return items
  end
  
  # Get top track info from Last.fm
  # TODO -- Cache this!
  def top_tracks
    items = []
    unless source_id.blank?
      tracks=Scrobbler::Artist.new(source_id).top_tracks[0..14]
      
      cat = ItemCategory.find_by_api_source("music-track")
      return [] if cat.blank?
      cat_id = cat.id
      
      items = []
      tracks.each do |track|
        if item = Item.find_by_source_id(/#{track.name}/i, :conditions=>{:category_id => cat_id})
          items << item
        else
          track.load_info
          items << Item.new(:name => track.name)
        end
      end
    end 
    return items
  end
  
  # Get related track info from Last.fm
  # TODO -- Cache this!
  def related_tracks
    tracks = Scrobbler::Track.new(self.artist, self.source_id).similar[0..13]
    
    cat_id = ItemCategory.find_by_api_source("music-track").id
    
    items = []
    tracks.each do |track|
      if item = Item.find_by_source_id(/#{track.name}/i, :conditions=>{:category_id => cat_id})
        items << item
      else
        track.load_info
        
        artist = Scrobbler::Artist.new(track.artist.name)
        artist.load_info
        
        # I'd prefer to grab the album image for a track
        #album = Scrobbler::Album.new(track.artist.name, ***track.album.name)
        
        items << Item.new(:name => track.name, :basic_image_url => artist.image_large)
      end
    end
    
    return items
  end
  
  # buy links
  # TODO -- Cache this!
  def buy_link
    if self.category.api_source == 'music-album'
      return Scrobbler::Album.new(self.artist, self.source_id).buy_link if self.artist
    elsif self.category.api_source == 'music-track'
      return Scrobbler::Track.new(self.artist, self.source_id).buy_link if self.artist
    end
  end
  
  def buy_track_link
    item = Scrobbler::Track.new(self.artist, self.source_id).buy_link
  end
  
  # Before Filter Method
  # save artist before saving track
  def save_artist_info
    if (cat = ItemCategory.find(self.category_id)) and (cat.api_source == 'music-track' || cat.api_source == 'music-album')
      unless artist = Item.find_by_name(/#{self.artist_name}/i)
        delay.get_artist_info
      end
    end
  end

  def get_artist_info
    scrobbler_artist = Scrobbler::Artist.new(self.artist_name)
    scrobbler_artist.load_info
    cat_id = ItemCategory.find_by_api_source("music-artist").id
    artist = Item.load_scrobbler_info(scrobbler_artist, {:category_id => cat_id })
    artist.save
    media = ItemMedia.new
    media.remote_image_url = scrobbler_artist.image_large
    media.primary = true
    media.save
    artist.medias << media
  end

  #################################################################################
  # END Music API Methods
  #################################################################################
  
  
  #################################################################################
  # Movie API Methods
  #################################################################################
  
  # Adding this method here so we do not have to include the "cast" key with every document
  def cast
    if self.instance_variable_defined?("@cast")
      if !self[:cast].nil?
        self[:cast].map {|member| Hashie::Mash.new(member)}
      end
    end
  end

  def director
    if self.instance_variable_defined?("@director")
       self[:director]
    end
  end

  def released
    if self.instance_variable_defined?("@released")
       self[:released]
    end
  end
  
  def budget
    if self.instance_variable_defined?("@budget")
       self[:budget]
    end
  end

  def revenue
    if self.instance_variable_defined?("@revenue")
       self[:revenue]
    end
  end

  def runtime
    if self.instance_variable_defined?("@runtime")
       self[:runtime]
    end
  end
  #################################################################################
  # END Movie API Methods
  #################################################################################

  #################################################################################
  # Event and Place API Methods
  #################################################################################

  def start_datetime
    if self.instance_variable_defined?("@start_datetime")
       self[:start_datetime]
    end
  end

  def end_datetime
    if self.instance_variable_defined?("@end_datetime")
       self[:end_datetime]
    end
  end

  def start_time
    if self.instance_variable_defined?("@start_time")
       self[:start_time]
    end
  end

  def end_time
    if self.instance_variable_defined?("@end_time")
       self[:end_time]
    end
  end

  def ticket_price
    if self.instance_variable_defined?("@ticket_price")
       self[:ticket_price]
    end
  end

  def venue_name
    #there was some ugly bug in old code, so same old items have venue_name in arrays
    #we can remove .to_s for new database
    if self.instance_variable_defined?("@venue_name")
       self[:venue_name].to_s
    end
  end

  def address
    if self.instance_variable_defined?("@address")
       self[:address]
    end
  end

  def city
    if self.instance_variable_defined?("@city")
       self[:city]
    end
  end

  def state
    if self.instance_variable_defined?("@state")
       self[:state]
    end
  end
  
  def country
    if self.instance_variable_defined?("@country")
       self[:country]
    end
  end
  
  def zip
    if self.instance_variable_defined?("@zip")
       self[:zip]
    end
  end


  def source_url
    if self.instance_variable_defined?("@source_url") and !self[:source_url].blank?
      self[:source_url]
    elsif source_name
     "http://#{self.source_name}"
    end
  end


  #################################################################################
  # END Event API Methods
  #################################################################################
  
  
  def self.most_hyped(limit = 15, ids=nil)
    #options =  {:order => 'review_count desc',  :limit => limit, :select => 'name, id, score, last_hyped_at'}
    options =  {:order => 'review_count desc',  :limit => limit}
    options.merge!(:user_id.in => ids) unless ids.nil?
    Item.all(options) 
  end

  def self.most_commented(limit = 7, ids=nil)
    options =  {:order => 'comment_count desc',  :limit => limit, :select => 'name, id, score, first_word_list, short_description, category_id'}
    options.merge!(:user_id.in => ids) unless ids.nil?
    Item.all(options) 
  end

  def self.top_rated(limit = 7, ids=nil)
    #options =  {:order => 'score desc',  :limit => limit, :select => 'name, id, score, first_word_list, short_description, category_id'}
    options =  {:order => 'score desc',  :limit => limit}
    options.merge!(:user_id.in => ids) unless ids.nil?
    Item.all(options) 
  end
  
  # argh! there are no unique identifiers
  def self.item_from_getglue(getglue_obj)
    Item.new(:source_id => 'glue:' + getglue_obj['title'], :name => getglue_obj['title'], 
             :short_description => getglue_obj['description'], :source_name => 'getglue.com')
  end

  def self.search_getglue_api(query, options={})
    glue_token = "epCC4suhV543IbFJ1fYXIvhGahHzVy7hri6CyexjI_z_VLaxa26N-1819708495"
    glue = Glue.new
    glue.glue_token = glue_token

    begin
      results = glue.glue.findObjects({:q => query})
    rescue => ex
      RAILS_DEFAULT_LOGGER.info "XXX #{ex.class}: #{ex.message}"
      return []
    end
    matches = results['adaptiveblue']['response']['matches']

    products = []
    matches.each do |k,v|
      unless ['topics','count'].include?(k)
        obj = v[k]
        if 1 == v['count'].to_i
          products << item_from_getglue(obj)
        else
          obj.each do |item|
            products << item_from_getglue(item)
          end
        end
      end
    end

    products
  end

  def self.search_web_api(query, options={})
    
    google_data = GoogleAjax::Search.web(query + ' about')
    
    sites = []
    # sample site {:unescaped_url=>"http://www.facebook.com/", :content=>"<b>Facebook</b> is a social utility that connects people with friends and others who   work, study and live around them. People use <b>Facebook</b> to keep up with friends,   <b>...</b>", :url=>"http://www.facebook.com/", :title_no_formatting=>"Welcome to Facebook", :title=>"Welcome to <b>Facebook</b>", :gsearch_result_class=>"GwebSearch", :cache_url=>"http://www.google.com/search?q=cache:QmfEpZb9ltYJ:www.facebook.com", :visible_url=>"www.facebook.com"}
    # we should pass in "url" as an optional parameter into that method
    # or change out "query" to be the url if it exists before calling the method
    # try using visible_url
    for site in google_data[:results]
      sites << Item.new(:name => site[:visible_url],  :short_description => site[:content], :source_id => site[:unescaped_url], :source_name =>'google.com')
    end
    return sites
  end

  def self.search_shopping_api(query, options={})   
    options[:page] ||= 1
    options[:per_page] ||= 5
    
    begin
    shopping_client ||= Shoppr::Client.new(true)
    # Get search data from API
    products = shopping_client.search(:keyword => query, :numItems => 10, :pageNumber => options[:page]).categories.map(&:products).flatten
    
    shopping_products = products[0..4].collect do |shopping_item|
      if Item.first(:source_id => shopping_item.id.to_s).blank?        
        product_id = shopping_item.id
    
        # Get the highest resolution image that exists by doing a select in reverse order looking for 
        # a url that does not have "no_image" in the url
        # this gets the biggest image #image_url = i.images.reverse.select {|image| !image.source_url.include?("no_image")}.first.source_url
        image_list = shopping_item.images.select {|image| !image.source_url.include?("no_image")}
        image_url = image_list.any? ? image_list.first.source_url : "/images/app/icon_hype_large.png"
    
         # Item.find_or_initialize_by_source_id(:source_id => product_id, :name => shopping_item.title, :image_url => shopping_item.stock_photo_url)
        Item.new(:source_id => product_id, :name => shopping_item.name, :short_description => shopping_item.full_description,  :basic_image_url => image_url, :source_name => 'shopping.com')
      end
    end     
    shopping_products.compact   
    rescue
    end
  end
  
  def self.search_artist_api(query, options={})
    options[:page] ||= 1
    options[:limit] ||= 5
    
    artists = Scrobbler::Artist.search(query, options)
    
    artist_items = self.load_scrobbler_info_array(artists, options)        
  end
  
  def self.search_album_api(query, options={})
    options[:page] ||= 1
    options[:limit] ||= 5
    
    albums = Scrobbler::Album.search(query, options)
    
    album_items = self.load_scrobbler_info_array(albums, options)    
  end
  
  def self.search_track_api(query, options={})
    options[:page] ||= 1
    options[:limit] ||= 5
    
    tracks = Scrobbler::Track.search(query, options)
    
    track_items = self.load_scrobbler_info_array(tracks, options)    
  end
  
  def self.search_event_api(query, options={})
    options[:page] ||= 1
    options[:per_page] ||= 5
    options[:sort] ||= 'popular-score-desc'
    
    events = Upcoming::Event.search(options.merge!(:search_text => query))
    event_items = self.load_upcoming_info_array(events, options)
    
  rescue Exception => e
    []
  end
  
  def self.search_movie_api(query, options={})
    options[:page] ||= 1
    options[:limit] ||= 5
    
    movies = @@tmdb.search(query)
    movie_items = self.load_moviedb_info_array(movies, options)
  end
  
  def self.search_people_api(query, options={})
    begin
      page = Wikipedia.find(query)
      content = page.content
      content = scrape_wikipedia_content(content)
    
      params = {:source_id => page.title, :source_name => 'wikipedia.org', :name => page.title, :short_description => content, :category_id => options[:category_id]}
      [Item.new(params)]
    rescue
      
    end
  end
  
  def self.scrape_wikipedia_content(content)
    # VARIANT WITH INFOBOX
    if !content.index(/\{\{Info/).nil?
      # this deletes the infobox section of the wiki
      # we might need alternate versions if we run into multiple
      content.gsub!(/\{\{Info.*\}\}\n'''/m, 'STARTSYNOPSIS')
      # I put in STARTSYNOPSIS to prevent some variants with ''' appearing in earlier info sections.

      # Delete all of the content below the synopsis.
      content.gsub!(/==.*/m, '')
  
      # Delete the remaining info above synopsis
      content.gsub!(/.*STARTSYNOPSIS/m, "'''")
    # VARIANT SANS INFOBOX
    else
      # when we don't have the info box, chances of running into this are much lower
      content = content[/'''.*/m] # get rid of everything before synopsis
      content.gsub!('==', "ENDSYNOPSIS") # place marker
      content.gsub!(/ENDSYNOPSIS.*/m, '') # delete everything from marker on
    end

    content = WikiCloth.new({:data => content}).to_html

    # makes sure we don't grab to much
    content.gsub!(/<\/a>]/i) {|s| s + "\n\n\n"}
    # get rid of ref links
    content.gsub!(/(\[<a href=.*<\/a>\])|(\n\n\n)/i, '')

    # get rid of ref links
    content.gsub!(/(<a href="javascript:void\(0\)">)|(<\/a>)/i, '')
    
    # IF MORE THEN ONE NEWLINE, REPLACE WITH A SINGLE NEWLINE
    content.gsub!(/(\n){2,}/, "\n")
    
    return content
  end
  
  def self.search_place_api(query, options={})
    google_data = GoogleAjax::Search.local(query, 32.90, 97.03)
    google_data = Mash.new(google_data)
    
    
    # this is just an idea I had, check wikipedia for info on the place.
    # for famous places, we can grab a nice description.
    begin
      page = Wikipedia.find(query)
      content = page.content
      description = scrape_wikipedia_content(content)
    rescue
      description = nil
    end
    results_array = []
    for result in google_data.results
      if description.nil?
        description = result.title_no_formatting
      end
      
      #~ address = result.street_address + ' ' + result.city + ', ' + result.country
      address = result.address_lines.to_sentence
      get_state = (result.state && result.state.nil? && result.state.blank?) ? result.state : result.region
      params = {:source_id => address, :source_name => 'wikipedia.org', :name => result.title_no_formatting + ' ' + address, :short_description => description,  :category_id => options[:category_id], :address => result.street_address, :city => result.city, :state => get_state, :country=> result.country}
      results_array << Item.new(params)
    end
    return results_array
  end
  
  #array of items
  def self.load_scrobbler_info_array(items, options={})
    items.collect do |item|
      Item.load_scrobbler_info(item)
    end    
  end
  
  # single item
  def self.load_scrobbler_info(item, options={})
      item.load_info   
      params = {:source_id => item.name, :source_name => "last.fm", :name => item.name, :short_description => item.summary,  :category_id => options[:category_id]}
      params.merge!({:artist_name => item.artist.name}) unless item.is_a?(Scrobbler::Artist)
      Item.new(params)
  end
  
  #array of items
  def self.load_moviedb_info_array(items, options={})
    items.collect do |item|
      Item.load_moviedb_info(item)
    end    
  end
  
  # single item
  def self.load_moviedb_info(item, options={})
      params = {:source_id => item.id, :source_name => "themoviedb.org", :name => item.name, :short_description => item.overview, :category_id => options[:category_id]}
      params[:released] = item.released.blank? ? nil : item.released.to_time
      
      Item.new(params)
  end
  
  #array of event items
  def self.load_upcoming_info_array(events, options={})
    events.collect {|event| Item.load_upcoming_info(event, options)}
  end
  
  #single event item
  def self.load_upcoming_info(event, options={})
    params = { :source_id => event.id,
               :source_name => "upcoming.yahoo.com",
               :name => event.name,
               :short_description => event.description,
               :category_id => options[:category_id],
             }
              
    item = Item.new(params)
    item.pull_event_data
    item
  end

  def self.search(query, options={:page => 1, :per_page => 10}, category_id = false)
    s = Sunspot.search(self) do
      keywords query
      if category_id
        with :category_id, category_id 
      end
      paginate(options)
    end
    s.results
  end
  
  def self.search_by_category(query, category_ids, options={:page => 1, :per_page => 1000})
    Sunspot.search(self) do
      keywords query
      with(:category_id, category_ids)
      paginate(options)
    end.results
  end
  
  # This method will run a search for a particular category and return 
  # the number of hits (items) in/under the category
  def self.category_search_count(query, category_id)
    # Build up child categories, if any
    search_cats = [category_id]
    if parent = ItemCategory.find(category_id)
      if parent.children.any?
        # Grab child category ids
        search_cats += parent.children.map(&:id)
      end
    end
    s = Sunspot.search(self) do
      keywords query
      with(:category_id, search_cats)
      facet(:category_id)
      paginate(:page => 1, :per_page => 1000)
    end
    # Return total hits
    return s.total
  end
  
  def self.search_external_api(query, api_source=nil, options={})
    items = case api_source
              when "product" : self.search_shopping_api(query, options)
              when "music-artist" : self.search_artist_api(query, options)
              when "music-album" : self.search_album_api(query, options)
              when "music-track" : self.search_track_api(query, options)
              when "movie" : self.search_movie_api(query, options)
              when "event" : self.search_event_api(query, options)
              when "person" : self.search_people_api(query, options)
              when "place" : self.search_place_api(query, options)
              #when "web" : self.search_web_api(query, options)
              when "web" : self.search_getglue_api(query, options)
              when "wikipedia" : self.search_people_api(query, options)
              else self.search_getglue_api(query, options)
            end
  end
  
  # rebuild all of this every time an item is saved
  def extract_search_terms
    # Store screen_name, name, description, etc into single search_keywords field
    field_names = [:name, :short_description ]
    terms = []
    field_names.each do |field|
      # Get all of the 3+ character words into an array
      terms << self.send(field).downcase.scan(/\w{3,}/) if self.send(field)
    end
    # Save the search terms as a space delimited string
    self.search_terms = terms.flatten.uniq.join(" ")
    
    tags = Label.all(:item_id => self.id)
    for tag in tags
      self.search_terms += ' ' + tag.tag
    end
  end
  
  # After save

  def remove_sunspot
    Sunspot.remove(self)
    Sunspot.commit
  end

  # Now reindex (this is done automatically in the Rails/AR plugin, but here we're on our own)
  # http://groups.google.com/group/ruby-sunspot/browse_thread/thread/39bd76fbd9c47692
  def reindex_sunspot
    Sunspot.index(self)
    Sunspot.commit
  end
  
  def delete_cache
    host = (RAILS_ENV == "development" ) ? "localhost:3000" : "test.thehypenetworks.com"
     ActionController::Base.new.expire_fragment("#{host}/items/#{self.id.to_s}?key=#{self.id.to_s}_details") 
    #ActionController::Base.new.expire_fragment("#{self.id.to_s}_details") 
  end
  
  ##########################################
  # 
  # iPhone API
  #
  ###########################################
   
  def item_type_tag
    self.category.name
  end

  def item_type_id
    self.category.integer_id
  end

  def thumbnail_url
    formatted_path(self.item_image)
  end

  def comments_count
    self.comment_count
  end

  def hypes_count
    self.review_count
  end
  
  def last_hyped
    self.last_hyped_at
  end
  
  def full_description
    self.short_description
  end
  
  def location
    self.address
  end
  
  def event_time
    self.start_datetime
  end
  
  def description_source_url
    self.source_url
  end

  
  def shares_count
    # not currently in the iPhone app
    nil
  end
  
  def images
    tab = []
    i = 0
    self.medias.each do |photo|
      item = Item.first(:id => photo.item_id, :select => 'integer_id')
      tab[i] = {
        :caption => photo.image_filename,
        :id => item.integer_id,
        :item_id => item.integer_id,
        :updated_at => photo.updated_at,
        :thumbnail_url => formatted_path(photo.image_url(:thumb)),
        :small_image_url => photo.image_url,
        :large_image_url => photo.image_url
      }
      i += 1
    end
    return tab
  end
  
  def average_metric_ratings
    tab = []
    tags = all_criteria(self.id)
    tab[0] = {:metric_tag => tags[0], :rating => self.criteria_1}
    tab[1] = {:metric_tag => tags[1], :rating => self.criteria_2}
    tab[2] = {:metric_tag => tags[2], :rating => self.criteria_3}    
    return tab
  end
  
  def spec_categories
    tab = []
    i = 0
    self.item_details.each do |it_det|
      specs = []        
      j = 0
      it_det.features.each do |feature|
        specs[j] = {
          :id => self.integer_id + i + j,
          :spec_category_id => self.integer_id + i,
          :updated_at => self.created_at,
          :name => feature[0],
          :value => feature[1]
        }
        j += 1
      end
      
      tab[i] = {
        :name => it_det.feature_group,
        :item_id => self.integer_id,
        :id => self.integer_id + i,
        :updated_at => self.created_at,
        :specs => specs
      }
      i += 1
    end
    return tab
  end
  
  def top_pros
   tab = []
   top_pros = LabelStat.all(:item_id => self.id, :type => "pro", :order => "value DESC", :limit => 3)
   i = 0
   top_pros.each do |tp|
     tab[i] = {
       :id => i,
       :type => "Pro",
       :text => tp.tag,
       :count => tp.value,
       :item_id => self.integer_id,
       :created_at => self.created_at,
       :updated_at => self.created_at
     }
     i += 1
   end   
   return tab
  end
  
  def top_cons
   tab = []
   top_cons = LabelStat.all(:item_id => self.id, :type => "con", :order => "value DESC", :limit => 3)
   i = 0
   top_cons.each do |tc|
     tab[i] = {
       :id => i,
       :type => "Con",
       :text => tc.tag,
       :count => tc.value,
       :item_id => self.integer_id,
       :created_at => self.created_at,
       :updated_at => self.created_at
     }
     i += 1
   end   
   return tab
  end

  def formatted_path(path)
    if path.first == "/"
      HOST + self.item_image
    elsif path[0..3] == "http"
      path
    else
      HOST + "/" + self.item_image
    end
  end

  ##########################################
  # 
  # end of iPhone API
  #
  ##########################################

  # similar items feature
  
  def matching_count(out_labels)
    (self.labels.collect {|e| e.tag}.uniq & out_labels.collect {|e| e.tag}.uniq).size
  end

  def similar_items(limit, ids)
  return [] if self.labels.empty?
    @result = []
    if ids
       @items = Item.all(:select => 'id, name, labels, category_id, image_url,score,score_color', :user_id.in => ids)
    else
       @items = Item.all(:select => 'id, name, labels, category_id, image_url,score,score_color')
    end
    if @items
      @matches = @items.collect do |e|
				if e.id
          if self.category_id == e.category_id
						[self.matching_count(e.labels), 1, e.id, e.name, e.item_image, e.category_id,e.score,e.score_color]
					else
						[self.matching_count(e.labels), 0, e.id, e.name, e.item_image, e.category_id,e.score,e.score_color]
					end
				end
      end.sort.reverse
      @matches.shift

      @new_matches=[]
      @matches && @matches.each do |e|
				if e[2]
					hash={:id=>e[2], :name=>e[3], :image_url=>e[4], :link =>item_path(e[2]), :category=>e[5],:score=>e[6],:score_color=>e[7]}
					@new_matches << hash
        
				end
      end

      (@matches.size > limit) ? (@temp = @matches.slice(0..limit-1)) : @result = @new_matches
      @temp && @temp.each do |e|
				if e[2]
					hash = {
						:id => e[2],
						:name => e[3],
						:image_url => e[4],
						:link => item_path(e[2]),
						:category => e[5],
            :score=>e[6],
            :score_color=>e[7]
					}
					@result << hash
				end
      end
    end
    return  @result
  end
  
	def matching_count_new(out_labels)
    (self.labels.collect {|e| e.tag if !e.type}.uniq & out_labels.collect {|e| e.tag if !e.type}.uniq).size
  end
	
  def similar_items_new(limit, ids)
    return [] if self.labels.empty?
    @result = []
    if ids
       @items = Item.all(:select => 'id, name, labels, category_id, image_url,score,score_color', :user_id.in => ids)
    else
       @items = Item.all(:select => 'id, name, labels, category_id, image_url,score,score_color')
     end
		 if @items
			@matches = @items.collect do |e|
					if self.category_id == e.category_id
						[self.matching_count_new(e.labels), 1, e.id, e.name, e.item_image, e.category_id,e.score,e.score_color]
					else
						[self.matching_count_new(e.labels), 0, e.id, e.name, e.item_image, e.category_id,e.score,e.score_color]
					end
			end.sort.reverse
			@matches.shift
		end
		@matches && @matches.each do |e|
        @result<<{:id=>e[2], :name=>e[3], :image_url=>e[4], :link =>item_path(e[2]), :category=>e[5],:score=>e[6],:score_color=>e[7]} if e.id
		end
    return @result.first(limit)
  end
  
  def get_item_custom_url
    if custom_item.nil?
      if (temp_custom_item = random_custom_item) and self.class.find_by_custom_item(temp_custom_item).nil?
        self.custom_item = temp_custom_item
        self.update_attributes(:custom_item => self.custom_item, :custom_url => "#{HYPE_CONFIG['short_url']}h/#{self.custom_item}", :item_url => "#{HYPE_CONFIG['site_url']}items/#{self.id}")
      else
        self.get_item_custom_url
      end
    end
    return self.custom_url
  end  
  
  def random_custom_item
		characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890'
		temp_custom_item = ''
		srand
		CUSTOM_ITEM_LENGTH.times do
			pos = rand(characters.length)
			temp_custom_item += characters[pos..pos]
		end
		temp_custom_item
	end




end


# Register this class in the Sunspot adapter (that we created ourselves)
Sunspot::Adapters::DataAccessor.register(MongoAdapter::DataAccessor, Item)
Sunspot::Adapters::InstanceAdapter.register(MongoAdapter::InstanceAdapter, Item)

Sunspot.setup(Item) do
  text :name, :boost => 2.0
  string :category_id do
    category.id
  end
  text :short_description
  #text :full_description
  text :search_terms
  text :tag_list do
    labels.map {|l| l.tag }.compact.uniq
  end
    
  # text :author_names do
  #   authors.map { |author| author.full_name }
  # end
  # string :title, :stored => true
  # integer :blog_id, :references => Blog
  # integer :category_ids, :references => Category, :multiple => true
  # float :average_rating
  # time :published_at
  # boolean :featured, :using => :featured?
  # boost { featured? ? 2.0 : 1.0 }
end
