module Api
  class ReviewsController < BaseResourceController

    def index
      @context = Item.find_by_integer_id(params[:item_id].to_i)
      @json_context_opts = {
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
      reviews = Review.paginate(paging_params.merge(:item_id => @context.id, :order => "created_at DESC"))
      @json_opts = {
         :methods => [
           :review, 
           :quality, 
           :value, 
           :utility, 
           :first_words, 
           :user_name, 
           :user_thumbnail_url, 
           :metric_ratings, 
           :item_integer_id,
           :pros_details,
           :cons_details
         ]
      }
      json_objects =  reviews.collect { |c| c.as_json(@json_opts) }
      response = { :paging => json_paging, :objects => json_objects }
      response.merge!(:context => @context.as_json(@json_context_opts || nil)) if @context
      render :json => response
    end

    def show
      @context = Item.find_by_integer_id(params[:item_id].to_i)
      @json_context_opts = {
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
      @json_opts = { 
        :methods => [
          :item_integer_id,
          :item_name, 
          :item_thumbnail,
          :review,
          :first_words, 
          :quality, 
          :value, 
          :utility,
          :metric_ratings,
          :user_name,
          :user_thumbnail_url,
          :user_details,
          :pros_details,
          :cons_details
          ] 
      }
      resource = Review.find_by_integer_id(params[:id].to_i)      
      res = resource.as_json(@json_opts)
      response = { :object => res }
      response.merge!(:context => @context.as_json(@json_context_opts || nil)) if @context
      render :json => response
    end

    def create      
      resource = Review.new
      user_id = resource.user_id = params[:hype][:user_id]
      resource.first_word_list = params[:hype][:first_words]
      resource.description = params[:hype][:review]
      resource.criteria_1 = params[:hype][:metric_ratings_attributes].values[0]
      resource.criteria_2 = params[:hype][:metric_ratings_attributes].values[1]
      resource.criteria_3 = params[:hype][:metric_ratings_attributes].values[2]
      integer_id = params[:item_id].to_i
      item_id = Item.find_by_integer_id(integer_id, :select => 'id').id
      resource.item_id = item_id
    
      # Because Rails uses parameters with the same key for arrays, which is challenging for the client, we allow
      # ids to be collected into a single parameter and break about here (commented by iPhone app team)
      pro_ids = con_ids = nil
      pro_ids = params[:hype][:pro_ids].split(',').collect(&:to_i) if params[:hype][:pro_ids]
      con_ids = params[:hype][:con_ids].split(',').collect(&:to_i) if params[:hype][:con_ids]
      
      pro_ids.each do |id|
        label_stat = LabelStat.find_by_type_and_integer_id("pro", id)
        Label.create(:user_id => user_id, :item_id => label_stat.item_id, :review_id => resource.id, :type => "pro", :tag => label_stat.tag)
      end

      con_ids.each do |id|
        label_stat = LabelStat.find_by_type_and_integer_id("con", id)
        Label.create(:user_id => user_id, :item_id => label_stat.item_id, :review_id => resource.id, :type => "con", :tag => label_stat.tag)
      end

      # Also, there seems to a bug with HABTM and nested parameters where it attempts to add two entries to the jump table when
      # the _ids are included in the params. So, we are doing the build in two phases (commented by iPhone app team)
      params[:hype].delete(:pro_ids)
      params[:hype].delete(:con_ids)
      pros_attributes = params[:hype].delete(:pros_attributes)
      cons_attributes = params[:hype].delete(:cons_attributes)       
      pros_attributes.values.each { |value| Label.create(:user_id => user_id, :item_id => item_id, :review_id => resource.id, :type => "pro", :tag => value["text"]) } if pros_attributes
      cons_attributes.values.each { |value| Label.create(:user_id => user_id, :item_id => item_id, :review_id => resource.id, :type => "con", :tag => value["text"]) } if cons_attributes

      if (resource.save)
        render :json => { :success => true, :id => resource.integer_id }
      else
        render :json => { :success => false, :errors => resource.errors.full_messages }
      end     
    end
  end
    
end
