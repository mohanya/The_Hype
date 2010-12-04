class SearchesController < ApplicationController
  skip_before_filter :set_facebook_session, :only => [:search_api, :search_local, :image, :autocomplete]
  
  def show    
    @page = params[:page] || 1
    @query = params[:query].to_s
    
    # Get search data from local database
    #if params[:search_type] == "user"
    # @user_results = User.login_or_email_like(@query).paginate(:page => @page)
    @user_results = User.search do
      keywords @query
      paginate(:per_page => 5, :page => @page)
    end.results
    #else
    # JD: commented this because it's commented inside the view so why run the search
    # @item_results = Item.search(@query, :per_page => 5, :page => @page)
    #end
    
    respond_to do |format|
      format.html
    end
  end
  
  def search_local
    @page = params[:page] || 1
    @query = params[:query].to_s
    type = params[:type]
    
    case type
      when 'user'
        results = User.search do
          keywords params[:query]
          paginate(:per_page => 5, :page => @page)
        end.results
        
        if results.length > 0
          render :partial => 'users/user', :collection => results
        else
          render :partial => 'searches/no_people_found'
        end
      when 'item'
        options = {:per_page => 5, :page => @page}
        category = ItemCategory.find(params[:category_id])
        if category
          category_id_search = if category.children.length > 0
            [category.id] + category.children.map(&:id)
          else
            category.id
          end
          results = Item.search_by_category(@query, category_id_search, options)
        else
          results = Item.search(@query, options)
        end
        
        if results.length > 0
          render :partial => 'searches/item', :collection => results
        else
          render :partial => 'searches/no_items_found'
        end
    end
  end
  
  def autocomplete
    query = params[:q]
    @item_results = Sunspot.search(Item) do
      keywords query
      paginate(:page => 1, :per_page => 10)
    end.results

    @user_results = Sunspot.search(User) do
      keywords query
      paginate(:page => 1, :per_page => 10)
    end.results
    
    @query = query

     render(:partial => 'searches/autocomplete')
  end

  def tags
    query = params[:q].include?(',')  ? params[:q].split(', ').last : params[:q]
    @tags = Tag.find(:all, :limit => 10, :conditions =>"name LIKE '#{query}%'", :select => 'name').collect{|x| x.name}
    #labels are not unique
    @labels =Label.find_all_by_tag(/#{query}/, :limit => 10, :select => 'tag').collect{|x| x.tag}
    @tags = (@tags + @labels).uniq
    render :layout => false
  end

  def image
    
    query = params[:query]
    #query.gsub!(/ {2,}/, '')
    options = {:imgsz => 'xlarge', :safe => 'active', :imgtype => 'photo', :start => params[:start].to_i * 4}
    if params[:category_id] and category = ItemCategory.find(params[:category_id])
      if params[:start].to_i > 2
        options.delete(:imgsz)
      end
      case category.api_source
        when 'product'
        
        when 'event'
          # imgtype is to experimental for us right now
          # we don't want to eliminate any potential pics for events
          options.delete(:imgtype)
          #query = query + ' event'
        when 'movie'
          query = query + ' movie'
        when 'place'
          
        when 'person'  
          #options[:imgtype] = 'face'
        when 'web'
          options.delete(:imgtype)
          # options.delete(:imgsz)
          # query.gsub!(/(www.)|(http\:\/\/)/i, '')
          # none of these are advantageous for image search
          query.gsub!(/(www.)|(http\:\/\/)|(.com\z)|(.edu\z)|(.org\z)|(.net\z)|(.co.uk\z)/, '')
          query = query + ' logo'
          # query = query + ' logo' #' OR screenshot'
        when 'music'
          query = query + ' music'
        when 'music-track'
          query = query + ' music'
        when 'music-artist'
          query = query + ' music'
        when 'music-album'
          query = query + ' album'
      end
    end
    
    # Find args here:
    # http://code.google.com/apis/ajaxsearch/documentation/reference.html#_fonje_image
    # Perhaps we can limit to just faces for people...
    google_data = GoogleAjax::Search.images(query, options)
    
    #render :xml => google_data
    render :partial => 'searches/google/image', :collection => google_data[:results]
  end
  
  def search_api
    item_category = ItemCategory.find(params[:source])
    if params[:source] == 'wikipedia'
      @items = Item.search_external_api(params[:query], 'wikipedia', params)
    elsif params[:source] == 'google_local'
      @items = Item.search_external_api(params[:query], 'place', params)
    elsif item_category.nil?
      @items = Item.search_external_api(params[:query], 'wikipedia', params)
    else
      @items = Item.search_external_api(params[:query], item_category.api_source, params)
    end
   if params[:type]
     type = params[:type]
   else
     type = (item_category && (item_category.name.underscore == 'place'  || item_category.name.underscore == 'event')) ? item_category.name.underscore : 'item'
   end
   render :partial => "searches/search_api/wikipedia", :layout => false, :locals => {:type => type}
  end

end
