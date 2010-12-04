class PasswordsController < ApplicationController
  
  layout "sessions.html.haml"

  def new
    if params[:email_error].nil?
      flash.clear
    end
  end

  def create
    if !params[:login_or_email].empty?
    
    if user = User.find_by_login(params[:login_or_email]) || User.find_by_email(params[:login_or_email])
      user.make_password_reset_code
      UserMailer.delay.deliver_forgot_password(user)
      flash[:notice] = "Password was send"
       respond_to do |format|
       format.html { redirect_to login_url }
      end
    else
      flash[:warning] = "We were unable to locate account for this email."
       respond_to do |format|
       format.html { redirect_to new_password_url(:email_error=>"invalid") }
       end
    end
    
    else
      flash[:warning] = "please enter your email address/user name."
       respond_to do |format|
       format.html { redirect_to new_password_url(:email_error=>"invalid") }
       end
    end
    
    
    
    
  end

  def edit
    @user = User.find_by_password_reset_code(params[:id])
    respond_to do |format|
      format.html
    end
  end

  def update
    @user = User.find_by_password_reset_code(params[:id])
    respond_to do |format|
      if ((!params[:user][:password].empty?) && (!params[:user][:password_confirmation].empty?))
        if @user.update_attributes(params[:user])
        UserMailer.delay.deliver_reset_password(@user)
        flash[:notice] = "Your password has been updated, please login."
        format.html {redirect_to login_url}
        else
        flash[:warning] = "We were unable to update your password, please try a different one."
        format.html {render :action => :edit}
        end
      else
        flash[:warning] = "We were unable to update your password, please enter password."
        format.html {render :action => :edit}
      end
    end
    
    
    
  end
  
end
