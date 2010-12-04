module Api
  class ActivitiesController < BaseResourceController
    def index
      @json_opts = {
        :methods => [
          :user_id,
          :activity_user_name,
          :user_thumbnail_url,
          :item_name,
          :item_type_tag,
          :item_integer_id,
          :item_thumbnail_url,
          :text
        ]
      }
      options = {:limit => 15}
      activities = []
      if params[:followings]
        begin
          current_user = User.find(params[:followings])
        rescue
        end
        activities = Activity.paginate(paging_params.merge(:user_id.in => current_user.friend_ids, :order => 'activity_date DESC')) if current_user        
      else
        activities = Activity.paginate(paging_params.merge(:order => 'activity_date DESC'))
      end
      json_objects =  activities.collect { |c| c.as_json(@json_opts) }
      response =  { :paging => json_paging, :objects => json_objects }
      render :json => response
    end
  end
end