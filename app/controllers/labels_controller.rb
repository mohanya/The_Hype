class LabelsController < ApplicationController

  def new
    @user = current_user
    @item = Item.find(params[:item_id])
    
    @label = Label.new(:item_id => @item.id)
    
    if request.xhr?
      render :layout => false
    end
  end

  def create
    @user = current_user
    @item = Item.find(params[:item_id])

    tags = params[:tags_string].split(',').map {|c| c.strip}
    
    for tag in tags
      @label = Label.create(:user_id => @user.id, :item_id => @item.id, :tag => tag)
    end

    Activity.delay.record(@item.labels.last(:order => 'created_at ASC').id, 'Label') if (@item.labels and !@item.labels.empty?)
    
    respond_to do |format|
        flash[:notice] = "Your tags have been saved."
        format.html {redirect_to item_url(@item)}
    end
  end
  
  def tag_cloud
    @tag_cloud = Item.find(params[:item_id]).tag_cloud

    render :json => @tag_cloud.to_json
  end
  
  def show
    
  end
    

end
