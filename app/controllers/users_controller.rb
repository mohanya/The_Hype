require 'youtube_g'
class UsersController < ApplicationController  
  before_filter :login_required, :only => [:edit, :update, :follow, :friends]
  before_filter :check_vanity_url, :only => [:show]
  layout "sessions.html.haml"

  def index
    @page = params[:page] || 1
    @per_page = params[:per_page] || User.per_page

    options = { :page => @page, :per_page => @per_page, :order => "login" }
    options[:conditions] = ['login like ?', "%#{params[:q]}%"] if params[:q]

    @users = User.paginate(options)

    respond_to do |format|
      format.html
      format.js { render :layout => false }
    end
  end

  def search
    # @users = User.search(params[:query])
    @users = User.search do
      keywords params[:query]
    end.results
    render :action => 'index'
  end

  # render new.rhtml
  def new
    if logged_in?
      redirect_to '/' and return
    end
    @user = User.new
    @data = {}
    @data_new = {}
    @user.build_profile
    if params[:invite] and @invite = Invite.find_by_id(params[:invite].split('-').last[/^\d+$/] == nil ? 0 : params[:invite].split('-').last )
       @user.email = @invite.email
    end
    if params[:id_provider]
      if 'facebook' == params[:id_provider]
        if self.current_user.nil?
          #~ @user = User.populate_from_fb_connect(facebook_session.user)
          @user.populate_from_fb_connect(facebook_session.user)
          @user.email = @invite.email if @invite
          @user.login=""
          @data = User.get_other_info(facebook_session.user)
        else
          self.current_user.link_fb_connect(facebook_session.user.id) unless self.current_user.fb_user_id == facebook_session.user.id
          redirect_to '/'
          return
        end
      else
        flash[:notice] = "Unsupported id provider."
      end
    end
    @partial_title = "Sign Up"
  end

  def create
    cookies.delete :auth_token
    # protects against session fixation attacks, wreaks havoc with 
    # request forgery protection.
    # uncomment at your own risk
    # reset_session
    @data_new={}
    if  ((params[:user][:profile_attributes]["birth_date(1i)"].blank?) || (params[:user][:profile_attributes]["birth_date(2i)"].blank?) || (params[:user][:profile_attributes]["birth_date(3i)"].blank? ))
      params[:user][:profile_attributes]["birth_date(1i)"]=""
      params[:user][:profile_attributes]["birth_date(2i)"]=""
      params[:user][:profile_attributes]["birth_date(3i)"]=""
    end
    @data = facebook_session ? User.get_other_info(facebook_session.user) : {}
    @data_new[:is_male]=params[:user][:profile_attributes][:gender]
    @user = User.new(params[:user])
    @user.fb_user_id = facebook_session.user.uid.to_i unless facebook_session.nil?
    @user.profile.tos = true
    
    # timezone setup
    GeoIp.api_key = get_twitter_keys['geoip_key']
    timezone_name = GeoIp.geolocation(request.remote_ip.to_s, {:precision => :city, :timezone => true})[:timezone_name] 
    @user.time_zone = timezone_name.split('/')[1] if timezone_name
    @user.profile.get_info_from_facebook(facebook_session.user) if facebook_session

    @user.register! if @user.valid?
    if @user.errors.empty?
      @user.activated!
      self.current_user = @user
      
      #calling method for send internal message
      send_internal_message
      
      cookies[:green_panel] =1
      session[:alpha_popup]=true
      redirect_to edit_user_favorites_path(:user_id=>@user, :created=>true)
      flash[:notice] = "Thank you for signing up! Please fill in the rest of your profile data."
    else
      render :action => 'new'
    end
  end

  def show
    redirect_to root_path() and return unless (Slug.exists?(:name=> "#{params[:id]}", :sluggable_type => "User") || (params[:id][/\A\d+\Z/] && User.exists?(params[:id])) || (params[:id].include?("--") && Slug.exists?(:name => "#{params[:id].split("--")[0]}", :sluggable_type => "User", :sequence => "#{params[:id].scan(/(\d+$)/).to_s}")))
    @user = User.find(params[:id]) || User.find(params[:id].split("--")[0])
    raise ActiveRecord::RecordNotFound unless @user
    redirect_to @user, :status => 301 and return if @user.has_better_id?
    @invite = Invite.new if @site.beta_invites?
    @reviews = @user.limited_reviews(5)
    #@followers = @user.followers.paginate(:per_page => 10, :page => params[:friends], :include => [:profile])
    @friends_count = @user.following
    @friends = @user.following.paginate(:per_page => 10, :page => params[:friends_page])
    @profile = @user.profile
    
    if logged_in?
      if friendship = Friendship.first(:conditions => ['user_id = ? AND friend_id = ?', current_user.id, @user.id], :select => 'id')
        @add_to_friends_display = "hide"
        @friends_display = ""
      else
        @add_to_friends_display = ""
        @friends_display = "hide"
      end
    end

    respond_to do |format|
      format.html
    end
  end
  
  def show_hypes
    @user = User.find(params[:id])
    @page = params[:reviews] || 1
    options = {:user_id => @user.id, :per_page => 8, :page => @page, :order => 'created_at DESC'}
    
    if params[:category_id]
      if category = ItemCategory.find(params[:category_id])
        category_id_search = if category.children.length > 0
          category.children.map { |child| "(#{child.id})" }.join('|')
        else
          category.id
        end
        options.merge!({:item_category_id => /#{category_id_search}/i})
      end
    end
    reviews = Review.paginate(options)
    #~ render :partial => 'reviews/review_block', :object => reviews
    render :partial => 'reviews/user_review_block', :object => reviews
  end
  
  def edit
    @user = current_user
    @site = SiteSetting.find(:first)
    render :layout => "profile.html.haml"
  end
  
  def update
    @user = current_user
    params[:user].delete(:password)
    params[:user].delete(:password_confirmation)
    @user.essentials = params[:user][:essentials] if params[:user].has_key?(:essentials)
    respond_to do |format|
      if @user.update_attributes(params[:user])
        
        flash[:notice] = "Your account has been updated."
        format.html { redirect_to user_url(@user) }
      else
        flash[:warning] = "There was a problem saving your account."
        format.html { render :action => :edit }
      end
    end
  end
  
  def invite
    @user = User.find(params[:id])
    if @user.invites > 0
      invite = Invite.new(:email => params[:invite][:email])
      invite.add_inviter(@user)
      if invite.save
        flash[:notice] = "An invite was sent to #{params[:invite][:email]}"
      else
        flash[:warning] = "That email address has already been invited"
      end
    else
      flash[:warning] = "You are out of invites"
    end
    respond_to do |format|
      format.html { redirect_to user_path(@user) }
    end
  end
  
  def activate

    self.current_user = params[:activation_code].blank? ? false : User.find_by_activation_code(params[:activation_code])
    if logged_in? && !current_user.active?
      current_user.activate!
      flash[:notice] = "Signup complete!"
    end
    redirect_back_or_default('/')
  end

  def follow
    @friend = User.find(params[:id])
    if 'true' == params[:follow]
      @friendship = current_user.friendships.build(:friend => @friend)
      if request.post?  and  @friendship.save
        render :text => 'Friend Added', :status => :ok
      end
    else
      @friendship = Friendship.first(:conditions => ['user_id = ? AND friend_id = ?', current_user.id, @friend.id])
      if request.post? and  (@friendship && @friendship.destroy)
        render :text => 'Friend deleted', :status => :ok
      end
    end
  end

  def delete_error
    render(:partial => 'delete_error', :layout => false)
  end
  
  
    def check_export_login
    @user =current_user
      if User.authenticate(@user.login,params[:password])
        export_csv
      else
        redirect_to export_my_data_user_profile_path(:user_id => current_user.id, :show_error => true)    
      end
    end
    


  def export_data_login_confirm
    @users =current_user
   render(:partial => 'export_data_login_confirm', :layout => false)
  end
  def delete_confirm
    render(:partial => 'delete_confirm', :layout => false)
  end
  
  def destroy
    @user = current_user
    if params[:sure] 
      if @user.authenticated?(params[:user][:password])
        User.delay.delete_with_all(@user.id)
        redirect_to '/logout' and return
      else
        flash[:warning] = "Cannot delete the account, password you provided is not valid"
        redirect_to delete_me_user_profile_path(@user) and return
      end
    else 
      redirect_to delete_me_user_profile_path(@user) and return
    end
  end

  def link_user_accounts
   if self.current_user.nil?
      #register with fb
      User.create_from_fb_connect(facebook_session.user)
    else
       #connect accounts
       flash[:notice]="your account has been linked from Facebook"
      self.current_user.link_fb_connect(facebook_session.user.id) unless self.current_user.fb_user_id == facebook_session.user.id
    end
    redirect_to :back
  end

  def unlink_user_accounts
    current_user.fb_user_id = nil
    current_user.save
    #Facebooker::User.unregister_emails(current_user.email)
    clear_facebook_session_information
    clear_fb_cookies!
    reset_session
    redirect_to root_url
  end

  def mutual_friends
    query = params[:q]
    limit = [(params[:limit] || 10).to_i, 10].min
    @mutual_friends = current_user.friends.with_name_like(query).limit_by(limit)
    render :layout => false
  end
  
  def export_csv
        #~ @user = User.find(params[:format])
       @comments = @user.comments
       @tips = @user.tips
       @outfile = "My_Hype_Datas_On" + Time.now.strftime("%m-%d-%Y") + ".csv"
       @profile=@user.profile
       @hypes=@user.reviews
    csv_data = FasterCSV.generate do |csv|
      csv << ["Profile Information"]
      csv << [""]
      csv <<["Name","#{@user.name}"]
      csv << ["Date Of Birth","#{@profile.birth_date}"]
      csv << ["Email","#{@profile.email}"]
      csv << ["City","#{@profile.city}"]
      csv << ["Country","#{@profile.country}"]
      csv << ["Job","#{@profile.job}"]
      csv << ["Education","#{@profile.education_level ? @profile.education_level.name : ''}"]
      csv << ["Website/Blog","#{@profile.blog}"]
      csv << ["Consumer Type","#{@profile.consumer_type ? @profile.consumer_type.name : ''}"]
      csv << ["Interests","#{@profile.interest_list}"]
      csv << ["Brands I Trust","#{@profile.trusted_brand_list}"]
      csv << []
      csv << ["Hyped"]  
      csv << []
      csv << [
    "Hyped On",
    "First thoughts that come to mind",
    "Score",
    "The Good",
    "The Bad"
     ]
     @hypes.each do |hype|
      csv << [
      hype.item_id,
      hype.first_word_list,
      hype.score,
      hype.pros.map(&:tag),
      hype.cons.map(&:tag),
      ]
  end
      csv << [""]
      csv << ["Comments"]  
      csv << [""]
      csv << ["Commented Type","Comments","Commented at","Replied To"]
    @comments.each do |comment|
      csv << [
      comment._type,
      comment.comment_text,
      comment.user_id_of_parent==nil ? 'new comment started by you' : "#{User.find(comment.user_id_of_parent).name}",
      comment.created_at.to_date
    ]
  end
    csv << []
    csv << ["Tips"]  
    csv << []
     csv << [
    "Tip",
    "Tip on",
    "Tip Score",
    "Tip given at"
     ]
    @tips.each do |tip|
      csv << [
      tip.advice,
      tip.item_id,
      tip.score,
      tip.created_at.to_date,
      ]
  end
  end
  send_data csv_data,
    :type => 'text/csv; charset=iso-8859-1; header=present',
    :disposition => "attachment; filename=#{@outfile}"
     #~ redirect_to export_my_data_user_profile_path(:user_id => current_user.id)    
   end
   
   def private_user
     user=User.find(params[:user_id])
   end
   
   def private_user_follow_request
     user=User.find(params[:user_id])
     render(:partial=>'private_user', :layout=>false, :locals=>{:user=>user})
   end
   
   def send_follow_request
     receiver=User.find(params[:receiver_id])
     UserMailer.deliver_follow_request(receiver,current_user)
     accept="<a href=/users/accept_or_reject_follow_request?follow=true&user=#{current_user.id}>Accept</a>"
     reject="<a href=/users/accept_or_reject_follow_request?follow=false&user=#{current_user.id}>Reject</a>"
     Message.create(:sender_id=>current_user.id, :receiver_id=>receiver.id, :subject=>"Follow request", :body=>"You have received a follow request from #{current_user.name.titleize}\n\n(#{accept} | #{reject})", :read=>false)
     flash[:notice]="Your request was sent"
     redirect_to root_path
   end
   
   def accept_or_reject_follow_request
     @friend=User.find(params[:user])
     @message=Message.new(:sender_id=>current_user.id, :receiver_id=>@friend.id, :read=>false)
    if 'true' == params[:follow]
      @friendship = @friend.friendships.build(:friend =>current_user)
      @friendship.save
      @message.subject="Follow request accepted"
      @message.body="Your follow request has been accepted by #{current_user.name.titleize}"
    else
      #~ @friendship = Friendship.first(:conditions => ['user_id = ? AND friend_id = ?', @friend.id, current_user.id])
      #~ @friendship.destroy
      @message.subject="Follow request rejected"
      @message.body="Your follow request has been rejected by #{current_user.name.titleize}"
    end
    @message.save
    flash[:notice]="Your response was sent"
    redirect_to inbox_messages_path
  end
  
  def alpha_phase
    render(:partial=>'alpha_phase', :layout=>false)
  end
  def vanity_validation
    vanity=''
    @username=User.find(:all, :select => "login").map(&:login) 
    if @username.include?(params[:username])
      vanity=true;
    else
      vanity=false;
    end    
    render :text=>vanity
  end
  #video selection
  def video_selection    
    client=YouTubeG::Client.new
    video_obj=client.videos_by(:key=>"phone")
    video_all=video_obj.videos
    embed_url=[]
    thumb_url=[]
    video_all.each do |url|
      embed_url<<url.embed_url
      thumb_url<<url.thumbnails[0].url
    end   
    render :text=>embed_url.join("::")+"::splitter::"+thumb_url.join("::")
  end
  
  private
  def check_vanity_url
    if Slug.exists?(:name=> "#{params[:id]}", :sluggable_type => "User") || (params[:id][/\A\d+\Z/] && User.exists?(params[:id]))
      return true
    elsif (params[:id].include?("--") && Slug.exists?(:name => "#{params[:id].split("--")[0]}", :sluggable_type => "User", :sequence => "#{params[:id].scan(/(\d+$)/).to_s}"))
      return true
    else
      return redirect_to page_path(:id => params[:id])  if params[:vanity]
    end    
  end  
  def  send_internal_message
   #send internal message to current user
   fakeadmin=User.find_by_login("TheHype")
   if fakeadmin
    @message = Message.new
    @message.sender_id =fakeadmin.id 
    @message.receiver_id=current_user.id
    @message.subject=""
    @message.body=User.message_body(current_user.login)
    @message.save
  end
end

end
