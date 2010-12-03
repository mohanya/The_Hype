class Friends::FacebooksController < ApplicationController
  before_filter(:login_required)
  
  def new
      @arr=[0];  
    if !params[:id_provider].nil?     
     begin
        if 'facebook' == params[:id_provider]
          #@p=facebook_session.user.pic_small
       #if facebook_session_expired
         #~ puts "-------------import friends-----------" 
         #~ facebook_session.send_notification([facebook_session.user], "<fb:fbml>some sweet fbml</fb:fbml>")
          #~ puts "post sent"
        @fri=facebook_session.user.friends()
        @face=facebook_session
        @h_friend_list=Hash.new()
        @h_friend_pics=Hash.new()
        @h_ids=Hash.new()
        @count=0
        @arr=Array.new()  
        @fri.each do |f|
           
           #~ puts f.name+" "+f.uid.to_s
         
          @h_user=User.find_by_fb_user_id(f.uid)
          @p=f.pic_small
          @h_friend_name=nil
          if @h_user
            @h_user_profile=@h_user.profile
            @h_fname=@h_user_profile.first_name 
            @h_lname=@h_user_profile.last_name
            if @h_fname && @h_lname
              @h_friend_name=@h_fname+" "+@h_lname
            elsif @h_fname
                @h_friend_name=@h_fname
            elsif @h_lname
                @h_friend_name=@h_lname
            end
          end  
        
        
        
        if @h_friend_name
          @h_friend_list[@h_user.fb_user_id]=@h_friend_name
          @count+=1
          @h_friend_pics[@h_user.fb_user_id]=@p if @p
          @h_ids[@h_user.fb_user_id]=@h_user.id
          @arr.push(@h_user.id)
        end
      end
      #~ puts @h_friend_list.inspect
      #~ puts ".0.0.0.0.0.0.0.0.00.00"
      #~ puts @arr.inspect
      #~ puts @arr.length
      #~ puts @arr.size
        #~ puts @h_friend_list.inspect
        #~ puts @h_friend_pics.inspect
        #~ puts "message sending----------"
         #~ facebook_session.user.publish_to(100000922282390, :message => "This is a post")
         #~ puts facebook_session.user.inspect
  
       #~ Facebooker::Session.create.send_notification(100000922282390, "hai hai --------")
       #~ TestPublisher.deliver_notification(100000922282390, facebook_session.user, 1, "2008", "first quarter")
       
        #~ facebook_session.send_notification([100000922282390,1793577893], "hype notification message")
        #~ puts "complete1"
        #~ facebook_session.send_email("hype","welcome hype",nil)
        #~ puts "msg sent"
        end
     
     rescue
        #~ puts "1.1.1.1.1.1.1.1.1.1.1."
        return facebook_session_expired
    end  
  end
  
  end


end
