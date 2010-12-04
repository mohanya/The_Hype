class Users::ProfilesController < ApplicationController

 #  def update
 #     @user = User.find(params[:user_id])
 #     @profile = @user.profile
 #     if @profile.update_attributes(params[:profile])
 #       flash[:notice] = "Your preferences have been saved"
 #     else
 #       flash[:error] = "Your preferences cannot be saved"
 #     end
 #     redirect_to edit_user_profile_url(@user)
 #   end
 # end

  before_filter :login_required
  
  def social_networks
    @user = User.find(params[:user_id])
    @profile = @user.profile
    respond_to do |format|
      format.html { render :template => 'users/profiles/social_networks', :layout => 'profile' }
    end
  end

  def delete_me
   @user = current_user
   render  :layout => 'profile' 
  end
  
  def edit
    @user = User.find(params[:user_id])
    @profile = @user.profile
    @site = SiteSetting.find(:first)
    GeoIp.api_key = get_twitter_keys['geoip_key']
    hash =GeoIp.geolocation(request.remote_ip.to_s, {:precision => :city, :country_name => true})
    @city = @user.profile.city ? @user.profile.city : hash[:city]
    @user.profile.country =  hash[:country_name] unless  @user.profile.country

    respond_to do |format|
      case params[:scope]
      when 'settings'
        format.html { render :template => 'users/profiles/settings' }
      when 'notices'              
        format.html { render :template => 'users/profiles/notices', :layout => 'profile' }
      when 'congrats'              
        format.html { render :template => 'users/profiles/congrats' }
      when 'social-networks'
        format.html { render :template => 'users/profiles/social_networks', :layout => 'profile' }
      else          
        format.html { render :template => 'users/profiles/edit' }
      end      
    end
  end
  
  def update
    @user = User.find(params[:user_id])
    if params[:user]
      params[:user].delete(:password)
      params[:user].delete(:password_confirmation)
      @user.essentials = params[:user][:essentials] if params[:user].has_key?(:essentials)
      params[:user][:profile_attributes].update({"private"=>false}) if (params[:user][:profile_attributes] && !params[:user][:profile_attributes][:private])
    end
   
    if @user.update_attributes!(params[:user])
      if params.has_key? 'save_and_exit'
        redirect_to user_url(@user)
      else
        redirect_to next_path_from_scope(params[:scope])
      end
    else
      flash[:warning] = "There was a problem saving your account."
      render :template => current_template_from_scope(params[:scope])
    end
  end
  
  def export_my_data
    @user = current_user
    render  :layout => 'profile' 
  end
  
  def privacy
    @user = current_user
    render  :layout => 'profile' 
  end
  
  def change_privacy
      return unless (request.put? && params[:user])
      user=User.find(params[:user_id])
      params[:user][:profile_attributes].update({"private"=>"false"}) if (params[:user][:profile_attributes] && !params[:user][:profile_attributes][:private])
      user.update_attributes!(params[:user])
      flash[:notice]="your settings has been saved"
      redirect_to user_url(user)
  end
  
private   
  def next_path_from_scope(scope)
    case scope
    when 'settings'
      scope_path(@user, 'congrats')
    when 'notices'
      user_url(@user)
    else
      scope_path(@user, 'settings')
    end
  end
  
  def current_template_from_scope(scope)
    case scope
    when 'settings'
      'users/profiles/settings'
    when 'notices'
      'users/profiles/notices'
    else
      'users/profiles/edit'
    end
  end
  
end

