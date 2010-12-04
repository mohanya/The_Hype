class LikesController < ApplicationController

  def create
     object = params[:type].capitalize.constantize.find(params[:id])
     @like = Like.new(:user_id => current_user.id)
     @like.object = object
     if @like.save 
        if object.is_a?(Activity)
          render(:partial => 'activities/like', :locals => {:activity => @like.object, :size => @like.object.likes.size})
        else
          render(:text => 'Liked')
        end
     else
        render(:text => 'Ups, something went wrong')
     end
  end
end
