class FriendshipsController < ApplicationController
  before_filter :login_required

  def create
    @friend = User.find(params[:friend_id])
    @friendship = current_user.friendships.build(:friend => @friend)
    if @friendship.save
      flash[:notice] = "Added friend."
      redirect_to root_url
    else
      flash[:notice] = "Unable to add friend."
      redirect_to root_url
    end
  end

  def destroy
    @friend = User.find(params[:friend_id])
    @friendship = current_user.friendships.find_by_friend_id(@friend.id)
    if @friendship.destroy
      flash[:notice] = "Removed friend."
      redirect_to root_url
    else
      flash[:notice] = "Unable to remove friend."
      redirect_to root_url
    end
  end

  #used on users page in community section to filter friends
  def index
    scope = params[:scope]
    @user = User.find(params[:id])
    if scope == 'global'
      @friends = @user.followers.paginate(:per_page => 10, :page => params[:friends_page])
      @friends_count = @user.followers
      friend_status = 'followers'
    else
      @friends = @user.following.paginate(:per_page => 10, :page => params[:friends_page])
      @friends_count = @user.following
      friend_status = 'following'
    end
    if !@friends.empty?
      render(:partial => 'users/user_block', :object => @friends, :locals => {:friend_status=>friend_status})
    else
      render(:partial => 'activities/no_friends', :locals => {:friend_status=>friend_status})
    end
  end
end
