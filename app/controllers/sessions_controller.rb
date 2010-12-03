# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  layout "sessions.html.haml"

  def new
    if logged_in?
      redirect_to '/' and return
    end
    @partial_title = "Login"
    session[:previous_page] = previous_page || root_url
  end

  def beta_login
   render(:layout => false)
  end

  def create
    session[:previous_page] ||= root_url
    self.current_user = User.authenticate(params[:login], params[:password])
    if logged_in?
      if params[:remember_me] == "1"
        self.current_user.remember_me
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      end
      cookies[:green_panel] =1
      redirect_back_or_default(session[:previous_page])
      flash[:notice] = "Logged in successfully"
    else
      u=User.authenticate(params[:login], params[:password])
      if u.nil?
        flash[:warning] = "Please check your username and password and try again."
      end
      if u && u.pending?
        flash[:warning] = "Please check your email and activate your account."
      elsif u && u.suspended?
        flash[:warning] = "Your account has been suspended, please contact an admin."
      elsif u and u.facebook_user?
        flash[:warning] = "Please check your username and password and try again."
      end
      render :action => 'new'
    end
  end

  def destroy
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    clear_facebook_session_information
    clear_fb_cookies!
    reset_session
    #flash[:notice] = "You have been logged out."
    redirect_to root_url
  end
  
  protected
  
  def previous_page
    if request.referer
      if previous_is_signup_signin_or_password_reset?
        root_url
      elsif request.referer.include?(request.domain)
        request.referer
      else
        root_url
      end
    end
  end
  def previous_is_signup_signin_or_password_reset?
    request.referer.include?("login") ||
    request.referer.include?("session") ||
    request.referer.include?("passwords") ||
    request.referer.include?("signup") ||
    (request.referer.include?('users') && request.referer.include?('new'))
  end
end
