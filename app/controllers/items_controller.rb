class ItemsController < ApplicationController  
  include ApplicationHelper

  before_filter :login_required, :except => [:show, :sub_categories, :additional_item_data, :graph]
  skip_before_filter :set_facebook_session, :only => [:favorite, :additional_item_data, :sub_categories]
  
  def index
    @items= get_items
    if request.xhr?
      render(:partial => 'items/item_block', :object => @items)
    else  
      respond_to do |format|
        format.html 
        format.js { render(:layout => false) }
      end
    end
  end


  def list
    @items= get_items
    render(:partial => 'items/item_block', :object => @items)
  end
  
  def filter
    limit = 3
    @ids = (params[:scope] == 'friends') ? current_user.friend_ids : nil
    case params[:type]
      when 'talked'
        @items = Item.most_commented(limit, @ids)
      when 'rated'
        @items = Item.top_rated(limit, @ids)
      when 'hyped'
        @items = Item.most_hyped(15, @ids)
      when 'all'
       options = {:page => @page, :per_page => 21, :order => "score desc"}
       @items = Item.paginate(options)
    end
    unless @items.empty?
      if params[:type] != 'hyped'
        render(:partial => 'item_preview', :collection => @items)
      else
        render(:partial => 'items/most_hyped', :object => @items)
      end
    else
      render(:partial => 'activities/no_friends')
    end
  end

  def autocomplete
    query = params[:q]
    limit = [(params[:limit] || 10).to_i, 10].min
    options = {:per_page => limit, :page => params[:page]}
    category_id = params[:category]
    @items = Item.search(query, options, category_id)
    respond_to do |format|
      format.js { render :layout => false }
    end
  end

  def show
    if params[:custom_item]
      item = Item.find_by_custom_item(params[:custom_item])
      return redirect_to item_path(item.id) if item
    end  
    if request.xhr?
      item = Item.first(:id => params[:id], :category_id => params[:category])
      @data = {}
      if item
        arr=item.reviews.find_all_by_user_id(current_user.id).map(&:activities).flatten.map(&:description)
        @data[:image_path] = item.item_image
        @data[:id] = item.id
        @data[:category] = singular_category_name(item.category)
        @data[:status] = "found"
        @data[:rating] = item.score.round.to_f.to_s
        if arr.include?("First hyped") || arr.include?("Hyped")
          @data[:already_hyped]=true
        else
          @data[:already_hyped]=false
        end
      else
        @data[:status] = "not found"
      end
      
      respond_to do |format|
        format.js {render(:json => @data.to_json) and return }
      end
    elsif @item =Item.find(params[:id])
      @partial_title = @item.name
      @ids = (current_user and params[:scope] == 'following') ? current_user.friend_ids  : false
      @page_description = @item.short_description
      options = {:parent_id => nil, :per_page => 10, :page => params[:comments]}
      @comments = @ids ? @item.comments.paginate(options.merge(:user_id.in => @ids)) : @item.comments.paginate(options)
       options = {:per_page => 8, :page => params[:reviews]}
      @reviews = @ids ? @item.reviews.paginate(options.merge(:user_id.in => @ids)) : @item.reviews.paginate(options)
      options = {:per_page => 4, :page => params[:tips], :order => 'score desc'}
      @tips = @ids ?   @item.tips.paginate(options.merge(:user_id.in => @ids)) : @item.tips.paginate(options) 
      options = {:order => 'activity_date ASC', :select => 'id, user_id, desc_for_item',  :source_id_string => @item.id}
      @activities = @ids ? Activity.all(options.merge(:user_id.in =>  @ids)) : Activity.all(options)
      @friendly_reviews = @reviews  if @ids 
      @score = @item.friendly_score(@friendly_reviews)
      @criteria = @item.friendly_criteria(@friendly_reviews)
      @best_comments = @item.best_comments(@ids)
      @medias = @item.medias.all(:order => 'created_at ASC')
      #~ @items = @item.similar_items(5, @ids)
      @items = @item.similar_items_new(5, @ids)
      
      # Added page keyword for the meta tag keyword
      keyword_str = "#{@item.name},#{@item.category_id},Reviews,Recommendations,Tips,Advice,Number of reviews - #{@item.reviews.length},#{@comments.collect(&:comment_text).join(',')},#{@reviews.collect(&:first_word_list).join(',')},#{@tips.collect(&:advice).join(',')}".gsub(/,{2,}/,',')
      @page_keywords = "#{keyword_str.gsub(/[\,]$/,'')}"
      
      if @reviews.size > 1
        options = {:order => 'score DESC'}
        options.merge!(:user_id => {'$in' => @ids}) if @ids
        @best_hype =   @item.reviews.first(options) 
        @worst_hype =  @item.reviews.last(options.merge!(:id => { '$ne' =>  @best_hype.id})) 
      end

      if current_user
        @item_favorite = ItemFavorite.first(:item_id => params[:id], :user_id => current_user.id, :favorite => true)
      end
        
      #For conversation comment form
      @commentable = @item
     
      # Bypass GoogleChart gem here in order to customize the meter chart how we like it
      meter_value = get_meter_value 
      @google_meter = Gchart.meter(:size => '240x120', :custom => "chco=1876bd,FFFF33,D40000&chf=bg,s,65432100&chd=t:#{meter_value}")
      @google_trends = Gchart.line(:size => '200x100', :data => @item.positive_trends.collect{|x| x[1]}, :custom => 'chm=B,538ad7,0,0,0&chf=bg,s,65432100', :line_colors => "4c7cbe")
      pross = @item.sum_label_counts('pro', @ids)
      conss = @item.sum_label_counts('con', @ids)
      
      if pross + conss > 0
        @google_sentiment = Gchart.pie_3d(:size => '250x110', :labels =>["#{((pross/(pross +conss)) * 100).to_i}%", "#{((conss/(pross +conss)) * 100).to_i}%"], :data => [pross, conss], :custom => 'chco=0077CC,ff0000&chf=bg,s,65432100')
      end
    else
      redirect_to search_path(:query => params[:id])
    end
  end
  
  def similar_items
    @item=Item.find(params[:id])
    if params[:scope] == 'friends'
      @ids=current_user.friend_ids
    else
      @ids=false
    end
    #~ @items = @item.similar_items(5, @ids)
    @items = @item.similar_items_new(5, @ids)
    render(:partial => 'item_hash', :locals => @items.first)
  end

  def graph
    @item = Item.find(params[:id])
    @ids = (params[:scope] == 'following') ? current_user.friend_ids : false
    meter_value = get_meter_value 
    @google_meter = Gchart.meter(:size => '680x380', :custom => "chco=1876bd,FFFF33,D40000&chf=bg,s,65432100&chd=t:#{meter_value}&chls=10|22")
    @pro_counts = @item.pro_counts(@ids)
    @con_counts = @item.con_counts(@ids)
    pross = @item.sum_label_counts('pro', @ids)
    conss = @item.sum_label_counts('con', @ids)
    @reviews_count = @ids ? @item.reviews.count(:user_id.in => @ids) : @item.reviews.count
    if pross + conss > 0
      @google_sentiment = Gchart.pie_3d(:size => '380x170', :labels =>["#{((pross/(pross +conss)) * 100).to_i}%", "#{((conss/(pross +conss)) * 100).to_i}%"], :data => [pross, conss], :custom => 'chco=0077CC,ff0000&chf=bg,s,65432100')
    end
    render(:layout => false)
  end
  
  def add #add item wizard
    item_type = params[:item][:_type]
    @item = item_type.classify.constantize.new(params[:item])
    case params[:step]
    when '2'
      @results = Item.search_external_api(@item.name, item_type)
    end
  end

  def sub_categories
    @parent_category = ItemCategory.find(params[:id])
    if @parent_category and @parent_category.children.length > 0
       render :partial => 'sub_category', :collection => @parent_category.children
    else
       render(:nothing => true)
    end
  end

  def additional_item_data
    if category = ItemCategory.find(params[:cid])
      case category.api_source
      when 'event'
        render :partial => 'items/new/additional_data/event'
      when 'place'
        render :partial => 'items/new/additional_data/place'
      else
        render :nothing => true
      end
    else
        render :nothing => true
    end
  end

  def new
    @item = Item.new # this is for user created item
    if (@link = @item.name || params[:query])
      first_link =  GoogleAjax::Search.web(@link)[:results].first
      @link = first_link[:url] if first_link
    end
    
    media = @item.medias.build
    respond_to do |format|
      format.html
      format.js { render :layout => false }
    end
  end

  def create
    @item = Item.new(params[:item])    
    @item.user_id = current_user.id
    @item.twitter_query = @item.name if @item.twitter_query.blank?
    @item.get_data_from_api if @item.source_id
    if extra = params[:additional_data] 
      @item.venue_name = params[:venue_name] if (params[:venue_name] && !params[:venue_name].blank?)
      extra[:start_datetime] = (extra[:start_datetime] + ' ' + extra[:start_time]).to_time unless extra[:start_datetime].blank? 
      extra[:end_datetime] = (extra[:end_datetime] + ' ' + extra[:end_time]).to_time  unless extra[:end_datetime].blank?
      if @item.category.api_source == 'place' and !extra[:address].blank?
        @item.source_id = extra[:address] + ', ' +extra[:city] + ' ' +extra[:state] + ' ' +extra[:country] + ' ' + extra[:zip]
      end
    end
    @item.set_additional_data(extra)
    @item.set_source_to_wikipedia if (params[:source_name] == 'wiki')
    respond_to do |format|
    if @item.save
        Label.delay.create_labels(@item.id, current_user.id, params[:tags_string])
        @we_have_primary_image = ItemMedia.create_one(@item, params[:primary_image], false) unless params[:primary_image].blank?
        if (params[:image_checkbox] and !params[:image_checkbox].empty?)
          Item.find(@item.id).update_attributes(:unfinished_images => true)
          ItemMedia.delay.create_many(@item.id, params[:image_checkbox],  @we_have_primary_image) 
        end
        format.js {render(:json => "{\"id\":\"#{@item.id}\",\"image_path\":\"#{@item.item_image}\", \"category\": \"#{plural_category_name(@item.category)}\"}")}
      end
    end
  end
  
  def update
    @item = Item.find(params[:id])
    respond_to do |format|
      if @item.update_attributes(params[:item])
        format.html do
          if params[:commit] == 'hype'
            redirect_to new_item_review_url(@item) 
          else
            redirect_to item_path(@item)
          end
        end
      else
        flash[:warning] = "There was a problem saving this item."
        format.html { render :action => :edit }
      end
    end
  end

  def edit
    redirect_to items_path
  end

  def refresh_images
    @item =  Item.first(:id => params[:id], :select => 'id')
    @last_media = @item.medias.find(params[:media_last_id]) if (params[:media_last_id] and !params[:media_last_id].blank?)
    if @last_media
       @medias = @item.medias.all(:created_at.gt =>  @last_media.created_at, :order => 'created_at ASC') 
    else
       @medias = @item.medias
    end
    if @medias and !@medias.empty?
      render(:partial => 'items/show/shared/image', :collection => @medias)
    elsif !@item.unfinished_images
      render(:text => 'stop')
    else
      render(:nothing => true)
    end
  end

  def favorite    
    @item = Item.first(:id => params[:id], :select => 'id, category_id')
    if request.post?  and  fave = current_user.set_favorite(@item)
      render :partial => 'items/favorite', :locals => {:item_favorite => fave, :item => @item}
    end
  end

  def trend
    @item = Item.find(params[:id])
      
    respond_to do |format|
      
      #JS is used for jqPlot charts
      format.js do 
        chart_data = @item.positive_trends
        render :json => chart_data
      end
      
      # CSV is used for AMCharts buzz chart
      format.csv do        
        csv_string = FasterCSV.generate do |csv|
          @item.positive_trends.each do |trend|
            # eliminate the -ve values
            if trend[1]>=0
              csv << [trend[0], trend[1]]
            end
          end
        end    
        render :text => csv_string
      end
    end  
  end

  def conversation_comment
    @item = Item.find(params[:id])
    @parent_comment = ItemComment.find(params[:parent_comment_id]) if !params[:parent_comment_id].blank?
    @comment = @item.comments.build
    @comment.parent = @parent_comment if !params[:parent_comment_id].blank?
    @comment.user_id = current_user.id
    logger.debug @comment.inspect
    if request.post? #form submitted
      @comment.comment_text = params[:comment_text]
      if @comment.save
        NotificationsJob.new(@comment).perform
        render :partial => 'items/conversation', :locals => {:comment => @comment}
      else
        render :text => 'Comments cannot exceed 3000 characters', :status => :unprocessible_entity
      end
    else #display the form
      render :partial => 'conversation_form'
    end
  end

  def get_items
    @page = params[:page] || 1

    @current_category = params[:category]

    options = {:page => @page, :per_page => 21, :order => "score desc", :select => 'id, score, name, category_id'}
    if params[:scope] == 'following' 
        options.merge!(:user_id.in => current_user.friend_ids)
    end
    if @current_category  and (parent = ItemCategory.find(@current_category))
      if parent.children.length > 0
        category_ids = [parent.id] + parent.children.collect(&:id).to_a
        options = options.merge({:category_id => {'$in' => category_ids}})
      else
        options = options.merge({:category_id => @current_category})
      end
    end
    
    @sort = params[:sort]
      case @sort 
        when 'top_rated'
          sort_option = {:order => 'score desc'}
        when 'most_recent'
          sort_option = {:order => 'created_at desc'}
        when 'most_hyped'
          sort_option = {:order => 'review_count desc'}
        when 'most_active'
          sort_option = {:order => 'comment_count desc'}
        else
          sort_option = {:order => 'score desc'}
      end
    
    options = options.merge(sort_option)
    @items = Item.paginate(options)
  end


  def get_meter_value
    #Set the Meter chart to go from 0 to 1500 for an items "velocity" (tweets per hour)
    # The Meter is looking for a number between 0 and 100
    begin
      meter_value = (@item.trends.last(:order => 'query_date ASC').mention_velocity/15)
    rescue Exception => e
      logger.info "Exception Caught: #{e.inspect}"
    end
    return meter_value
  end

  def parse_google_url(google_url)
    s = google_url.split(":").last
    image_url = (s.starts_with?("//") ? 'http:' : 'http://') + s
    CGI.unescape(image_url)
  end
  
  def already_hyped
    render(:partial => 'already_hyped', :layout => false)
  end


end


