class Admin::UsersController < AdminController
  before_filter :find_user, :except => [:index]

  def index
    @active_users = User.find_in_state(:all, :active)
    @pending_users = User.find_in_state(:all, :pending)
    @suspended_users = User.find_in_state(:all, :suspended)
    @passive_users = User.find_in_state(:all, :passive)
    
    respond_to do |format|
      format.html
    end    
  end

  def show
    respond_to do |format|
      format.html
    end
  end

  def edit
    
  end

  def update
    respond_to do |format|
      if @user.update_attributes(params[:user]) 
        @user.profile.update_attributes(params[:profile])
        format.html { redirect_to admin_users_url }
      else
        format.html { render :action => :edit }
      end
    end
  end

  def activate
    @user.activate! unless @user.active?
    
    respond_to do |format|
      format.html { redirect_to admin_users_url }
    end
    
  end

  def make_admin
    @user.promote!
    
    respond_to do |format|
      format.html { redirect_to admin_users_url }
    end
    
  end
  
  def remove_admin
    @user.demote!
    
    respond_to do |format|
      format.html { redirect_to admin_users_url }
    end
    
  end
  
  def suspend
    @user.suspend! 
    redirect_to admin_users_path
  end

  def unsuspend
    @user.unsuspend! 
    redirect_to admin_users_path
  end

  def destroy
    @user.delete!
    redirect_to admin_users_path
  end

  def purge
    @user.destroy
    redirect_to admin_users_path
  end
  
  private
  
  def find_user
    @user = User.find(params[:id])
  end
  
end
