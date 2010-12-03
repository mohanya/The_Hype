class PagesController < ApplicationController
  
  def index
    if logged_in?
      limit= 3
      @news = Info.last(:conditions => ['visible', true], :order => 'created_at ASC', :select => 'headline, id')
      @ids = current_user.friend_ids
      @stream = Activity.get_stream({:limit => 15, :user_id.in => @ids})
      @most_hyped = Item.most_hyped(15, @ids)
      @top_rated = Item.top_rated(limit, @ids)
      @most_commented = Item.most_commented(limit, @ids)
      render :layout => 'homepage'
    else
      render(:action => 'landing', :layout => 'landing')
    end
  end

  def landing
     render(:action => 'landing', :layout => 'landing')
  end
  
  def beta_contact
     render(:layout => 'landing')
  end

  def show
    id = params[:id]
    page_id = id.blank? ? 'pages/home' : "pages/#{id}"
    @partial_title = id.blank? ? "Home" : id
    if template_exists?(page_id)
      render :template => page_id, :layout => "page.html.haml"
    else
      #~ raise ActiveRecord::RecordNotFound, "Couldn't find the page #{page_id}"
      redirect_to root_path()
    end
  end

  def about
    render(:layout => 'sessions.html.haml')
  end
  
  private
  
  
  def template_exists?(path)
    self.view_paths.find_template(path, response.template.template_format)
    rescue ActionView::MissingTemplate
      false
  end
end
