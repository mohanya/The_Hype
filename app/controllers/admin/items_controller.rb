class Admin::ItemsController < AdminController
  before_filter :find_item, :except => [:index]
  after_filter :update_trends, :only => [:update]

  def index
    if params[:category]
      @category = ItemCategory.find(params[:category])
    else
      @category = ItemCategory.all.first
    end
    @items = Item.all(:category_id => @category.id, :order => 'created_at DESC', :select => 'name, created_at, id, twitter_query') 
    respond_to do |format|
      format.html
    end    
  end
  
  def edit
    @end_date = @item.end_datetime.strftime("%B, %e %Y")  if  (@item.end_datetime and !@item.end_datetime.blank?)
    @start_date = @item.start_datetime.strftime("%B, %e %Y") if  (@item.start_datetime and !@item.start_datetime.blank?)
    @end_time = @item.end_time
    @start_time = @item.start_time
  end
  
  def update
    respond_to do |format|
      if @item.category.api_source == 'place' 
        @item.source_id = params[:item][:address] + ', ' +params[:item][:city] + ' ' + params[:item][:state] + ' ' + params[:item][:zip]
      elsif @item.category.api_source == 'event'
        params[:item][:start_datetime] = (params[:start_date] + ' ' +params[:start_time]).to_time if (params[:start_date] and !params[:start_date].blank?)
        params[:item][:end_datetime] =   (params[:end_date] + ' ' + params[:end_time]).to_time if (params[:end_date] and !params[:end_date].blank?)
        params[:item][:start_time] = params[:start_time] if (params[:start_time] and !params[:start_time].blank?)
        params[:item][:end_time] = params[:end_time] if (params[:end_time] and !params[:end_time].blank?)
      end
      
        for media in @item.medias
          if !params[:existing_image_checkbox] || !(params[:existing_image_checkbox].has_value?(media.id.to_s))
            # if the image isn't a primary image
            if (params[:primary_image] != media.id.to_s) 
              puts "delete media: " + media.id.to_s + "\n\n"
              ItemMedia.destroy(media.id)
            else
              if previous_primary = ItemMedia.first(:item_id => @item.id, :primary => true, :id => {'$ne' => media.id})
                previous_primary.primary = false
                previous_primary.save
              end
              media.primary = true
              media.save
            end
          end
        end
        # only if it is a url here.
        if params[:primary_image].match(/http\:\/\/.*/i)
          begin
            media = ItemMedia.new
            media.remote_image_url = params[:primary_image]
            media.primary = true
            if previous_primary = ItemMedia.first(:item_id => @item.id, :primary => true, :id => {'$ne' => media.id})
              previous_primary.primary = false
              previous_primary.save
            end
            if media.save
              @item.medias << media
            end
          rescue
            puts "Failure Saving Primary Image: " + params[:primary_image] + "\n\n"
          end
        end
      ItemMedia.delay.create_many(@item.id, params[:image_checkbox],  true) if (params[:image_checkbox] and !params[:image_checkbox].empty?)
      if Item.find(@item.id).update_attributes(params[:item]) 
        format.html { redirect_to admin_items_url(:category => @item.category.id)}
      else
        format.html { render :action => :edit }
      end
    end
  end

  def destroy
    item = Item.find(params[:id])
    item.destroy
    flash[:notice] = "That item has been removed."
    
    respond_to do |format|
      format.html { redirect_to admin_items_url }
    end
  end

  private
  
  def find_item
    @item = Item.find(params[:id])
  end
  
  def update_trends
    # If a record is updated, delete the last 7 trends and repull from Twitter
    @item.trends.delete_if {|t| t.query_date.nil? || t.query_date > 7.days.ago.to_date}
    @item.delay.fetch_all_trends('twitter')
  end
  
end
