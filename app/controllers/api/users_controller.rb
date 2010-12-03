module Api
  class UsersController < BaseResourceController
    
    def login
      @user = User.authenticate(params[:username], params[:password])
      if @user
        render :json => { :success => true,
                          :credentials => { :user_id => @user.id, :username => @user.login, :password => @user.crypted_password } }
      else
        render :json => { :success => false }, :status => :unauthorized
      end
    end
  end
end