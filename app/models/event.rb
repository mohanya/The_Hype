class Event < Item
  has_friendly_unique_id :name  
  
  key :_id, String 
  key :event_date, DateTime
  key :venue, String 
end