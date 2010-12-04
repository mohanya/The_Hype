class Notice < ActiveRecord::Base
  belongs_to :user
  belongs_to :sender, :class_name => "User"

   def info
     case about
     when "Reply"
       return "Replied to your comment on item:" 
     when "Follow"
       return "Is now following you"
     when "Message"
       return "Sent you a message"
     when "Request"
      return "has sent you a request to follow"
     when "Request accepted"
      return "has accepted your follow request"
     when "Request rejected"
      return "has rejected your follow request"
     else
       return "dupa"
     end
   end

   def item
     Item.find(item_id)
   end

   def self.remove
      Notice.destroy_all(['created_at < ?', 15.minutes.ago ])
   end
end
