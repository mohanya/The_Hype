class Trend
  include MongoMapper::Document

  belongs_to :item, :foreign_key => :item_id
  key :source, String  # e.g. "twitter"
  key :query_date, Date
  key :begin_time, Time
  key :end_time, Time
  key :mention_count, Integer
  key :mention_velocity, Float
  key :item_id, String 

  def velocity(query, query_date = 1.day.ago.utc)
    if self.source == 'twitter'    
      search = Twitter::Search.new(query).since_date(query_date.to_date).until_date(query_date.to_date).per_page(100)
      tweets = search.fetch.results rescue nil
      tweet_velocity(tweets) if tweets
    elsif self.source == 'facebook'
      mentions = FGraph.search(query, {:limit => 100, :since => query_date.beginning_of_day, :until => query_date.end_of_day}) rescue nil
      facebook_velocity(mentions) if mentions
    end
      
  end

  # This will create a new Trend with a "twitter" source and a velocity based on the 
  # query and query_date.  This will NOT save the trend to the database.
  def tweet_velocity(tweets)      
    # If the tweet size is < 100, use the beginning of day as start time; 
    # Else, use the time of the first tweet
    self.begin_time = tweets.size < 100 ? query_date.beginning_of_day.to_datetime : tweets.last.created_at.to_datetime
    self.end_time = tweets.empty? ? query_date.end_of_day.to_datetime : tweets.first.created_at.to_datetime    
    self.mention_count = tweets.size
    self.query_date ||= query_date.to_date
  
    # Get the hours between the begin and end dates to be used in calculating velocity
    hours = (self.end_time - self.begin_time)/3600
    self.mention_velocity = self.mention_count / hours
    
    return self
  end
  
  # Same as tweet_velocity only for Facebook
  def facebook_velocity(mentions)   
    # If the facebook mention size is < 100, use the beginning of day as start time; 
    # Else, use the time of the first tweet
    self.begin_time = mentions.size < 100 ? query_date.beginning_of_day.to_datetime : mentions.last["created_time"].to_datetime
    self.end_time = mentions.empty? ? query_date.end_of_day.to_datetime : mentions.first["created_time"].to_datetime   
    self.mention_count = mentions.size
    self.query_date ||= query_date.to_date
  
    # Get the hours between the begin and end dates to be used in calculating velocity
    hours = (self.end_time - self.begin_time)/3600
    self.mention_velocity = self.mention_count / hours
      
    return self

  end
end
