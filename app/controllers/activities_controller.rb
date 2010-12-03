class ActivitiesController < ApplicationController
  before_filter :login_required
  skip_before_filter :find_site, :only => [:more]
  skip_before_filter :set_facebook_session, :only => [:more]

  def index
    options = {:limit => 15}
    options.merge!(:offset => params[:offset]) if !params[:offset].blank?
    if params[:scope] == 'friends'
      @activities = Activity.get_stream(options.merge(:user_id.in => current_user.friend_ids))
    else
      @activities = Activity.get_stream(options)
    end

    if !@activities.empty?
      render(:partial => 'activity', :collection => @activities)
    else
      render(:partial => 'no_friends')
    end 
  end
  
  def more
     object = Activity.find(params[:id])
     @replies = object.comments[2..-1]
     if @replies
        render(:partial => 'activities/reply', :collection => @replies)
     end
  end

  def latest
     time = Time.parse(params[:time]).utc
     scope = params[:scope]
     if scope == 'friends'
       count = Activity.count(:user_id.in => current_user.friend_ids, :created_at.gt => time)
     else
       count = Activity.count(:created_at.gt => time)
     end
     render(:text => count.to_s)
  end

  def show_latest
     time = Time.parse(params[:time]).utc
     scope = params[:scope]
     if scope == 'friends'
       @activities = Activity.get_stream(:user_id.in => current_user.friend_ids, :created_at.gt => time)
     else
       @activities = Activity.all(:created_at.gt => time)
     end
     render(:partial => 'activity', :collection => @activities)
  end

  def reply_form
    @activity = Activity.find(params[:id])
    @comment = @activity.comments.build
    @comment.parent = @activity.comment
    @comment.user_id = current_user.id
    @commentable = @activity
    render :partial => 'activities/reply_form'
  end


end
