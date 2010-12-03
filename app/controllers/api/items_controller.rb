module Api
  class ItemsController < BaseResourceController

    def index
      if params[:most_hyped]
        @items = Item.paginate(paging_params.merge(:order => 'review_count DESC'))
      elsif params[:top_Rated]
        @items = Item.paginate(paging_params.merge(:order => 'score DESC'))
      elsif query = params[:search] and query != ' '
        @items = Item.paginate(paging_params.merge(:name => /#{query}/i))
      else
        @items = Item.paginate(paging_params.merge(:order => 'created_at DESC'))
      end

      @json_opts = {
        :methods => [
          :item_type_tag, 
          :item_type_id,
          :thumbnail_url, 
          :comments_count, 
          :hypes_count,
          :last_hyped,
          :full_description,
          :description_source_url,
          :location,
          :event_time,
          :shares_count,
          :average_metric_ratings
        ]
      }
      json_objects =  @items.collect { |c| c.as_json(@json_opts) }
      response =  { :paging => json_paging, :objects => json_objects }
      response.merge!(:context => @context.as_json(@json_context_opts || nil)) if @context
      render :json => response
    end

    def show
      @item = Item.find_by_integer_id(params[:id].to_i)
      
      # Set the Meter chart to go from 0 to 1500 for an items "velocity" (tweets per hour)
      # The Meter is looking for a number between 0 and 100
      begin
        meter_value = (@item.trends.last(:order => 'query_date ASC').mention_velocity/15)
      rescue Exception => e
        logger.info "Exception Caught: #{e.inspect}"
        meter_value = 0
      end
      
      @ids = (current_user and params[:scope] == 'following') ? current_user.friend_ids  : false
      @google_meter = Gchart.meter(:size => '385x184', :custom => "chco=1876bd,FFFF33,D40000&chf=bg,s,65432100&chd=t:#{meter_value}")
      @google_trends = Gchart.line(:size => '529x360', :data => @item.positive_trends.collect{|x| x[1]}, :custom => 'chm=B,538ad7,0,0,0&chf=bg,s,65432100', :line_colors => "4c7cbe")

      pross = @item.sum_label_counts('pro', @ids)
      conss = @item.sum_label_counts('con', @ids)
      if pross + conss > 0
        percent_positive = ((pross/(pross+conss))*100).to_i
        percent_negative = ((conss/(conss+pross))*100).to_i
      end
      @google_sentiment = Gchart.pie_3d(:size => '453x226', :labels =>["#{percent_positive}%", "#{percent_negative}%"], :data => [pross, conss], :custom => 'chco=0077CC,ff0000&chf=bg,s,65432100')
     
      @json_params = {
        :meter => {
          :id => @item.integer_id,
          :item_id => @item.integer_id,
          :small_image_url => @google_meter,
          :large_image_url => @google_meter,
          :small_image_width => 385,
          :small_image_height => 184,
          :large_image_width => 385,
          :large_image_height => 184,
          :updated_at => @item.updated_at,
          :reading => "Cool",
          :value => meter_value
        },
        :sentiment => {
          :id => @item.integer_id,
          :item_id => @item.integer_id,
          :percent_positive => percent_positive,
          :small_image_url => @google_sentiment,
          :large_image_url => @google_sentiment,
          :small_image_width => 453,
          :small_image_height => 226,
          :large_image_width => 453,
          :large_image_height => 226,
          :updated_at => @item.updated_at
        },
        :buzz => {
          :id => @item.integer_id,
          :item_id => @item.integer_id,
          :small_image_url => @google_trends,
          :large_image_url => @google_trends,
          :small_image_width => 220,
          :small_image_height => 150,
          :large_image_width => 529,
          :large_image_height => 360,
          :updated_at => @item.updated_at
        }
      }
      
      @json_opts = {
        :methods => [
          :item_type_tag, 
          :item_type_id,
          :thumbnail_url, 
          :comments_count, 
          :hypes_count,
          :last_hyped,
          :full_description,
          :description_source_url,
          :location,
          :event_time,
          :shares_count,
          :average_metric_ratings,
          :images,
          :spec_categories,
          :top_pros,
          :top_cons
        ]
      }

      res = resource.as_json(@json_opts)
      res["item"].update(@json_params) if @json_params 
      response = { :object => res }
      render :json => response
    end
  end
end
