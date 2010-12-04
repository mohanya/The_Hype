# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  include HoptoadNotifier::Catcher
  helper :all # include all helpers, all the time
  before_filter :set_facebook_session
  helper_method :facebook_session
  before_filter :set_time_zone,  :unless => :its_ajax
  before_filter :find_site,  :unless => :its_ajax
 # filter_parameter_logging :password
 rescue_from Facebooker::Session::SessionExpired, :with => :facebook_session_expired

  
  
  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '9f8b77b17c7fe8f7e223e659927fb689'
  
  protected

  def shopping_client
   # @shopping_client ||= Shoppr::Client.new(!Rails.env.production?)
    @shopping_client ||= Shoppr::Client.new(true)
  end

  def set_time_zone
      Time.zone = current_user.time_zone if logged_in?
  end
  
  def its_ajax
    request.xhr?
  end
  
  def admin_required
    @site = SiteSetting.find(:first)
    (logged_in? && current_user.admin?) || admin_denied
  end
  
  def admin_denied
    respond_to do |format|
      format.html do
        store_location
        flash[:warning] = "You need admin privileges for that."
        redirect_to '/'
      end
    end
  end
  
  def find_site
    @site ||= SiteSetting.find(:first, :order => 'id ASC', :select => 'name, id, beta_invites')
  end
  
  def get_twitter_keys
    if RAILS_ENV=='production'
      @twitter_keys = YAML::load(File.open("#{RAILS_ROOT}/config/external_apis.yml"))['twitter']['production']
      
    elsif RAILS_ENV=='development' or RAILS_ENV=='test'
      @twitter_keys = YAML::load(File.open("#{RAILS_ROOT}/config/external_apis.yml"))['twitter']['development']
    end
  end

  def find_user
    if current_user
      @user = User.find(current_user.id)
    end
  end

  def facebook_session_expired
    clear_facebook_session_information
    clear_fb_cookies!
    reset_session # i.e. logout the user
    flash[:notice] = "You have been disconnected from Facebook."
    redirect_to root_url
  end
  
  # iPhone API
  
  def paging_params
    { :page => (params[:page] || 1), :per_page => (params[:per_page] || 10).to_i }
  end

   if ((RAILS_ENV == "productionn") || (RAILS_ENV == "developmenttt") )     
    rescue_from Exception, :with => :page_problem
    rescue_from ActiveRecord::RecordNotFound, :with => :not_found
    rescue_from ActionController::RoutingError, :with => :not_found
    rescue_from ActionController::MethodNotAllowed, :with => :not_found
    rescue_from ActionController::UnknownAction, :with => :not_found
  end
  
  def not_found(exception)
    redirect_to page_not_found_url
  end
  
  def page_problem(exception)
    redirect_to page_error_url
  end
  
end
