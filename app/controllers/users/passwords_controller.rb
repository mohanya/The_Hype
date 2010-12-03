class Users::PasswordsController < ApplicationController
  layout 'profile'
  before_filter :login_required
  before_filter :find_user
  
  def edit
  end
  
  def update
    @user.current_password = params[:user][:current_password]
    @user.password = params[:user][:password]
    @user.password_confirmation = params[:user][:password_confirmation]
    @user.password_being_changed = true
    
    if @user.save
      flash[:notice] = "Password successfully changed."
      redirect_to edit_user_password_url(@user)
    else
      render :edit
    end
  end
  
  private 
  def find_user
    @user = current_user
  end
end
