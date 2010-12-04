require 'spec_helper'

describe Users::ProfilesController do
  
  before(:each) do
    Profile.default_url_options[:host] = 'test.host'
    #User.delete_all
    @user = User.make
    User.stub!(:find).and_return(@user)
  end
  
  describe "GET edit" do
    it "should render edit template when scope is empty" do
      session[:user_id] = @user.id
      
      @controller.should_receive(:render).with({:template => 'users/profiles/edit'})
      get :edit, :user_id => @user.id
      response.should be_success
      assigns[:user].should == @user
    end
    
    it "should render settings template when scope equals 'settings'" do
      session[:user_id] = @user.id
      
      @controller.should_receive(:render).with({:template => 'users/profiles/settings'})
      get :edit, :user_id => @user.id, :scope => 'settings'
      response.should be_success
      assigns[:user].should == @user
    end
  end
  
  describe "POST update" do
    
    it "should redirect to user path on success when clicked save and exit" do
      session[:user_id] = @user.id
      @user.should_receive(:update_attributes).and_return(true)
      @controller.should_not_receive(:render)
      post :update, :user_id => @user.id, 'save_and_exit' => "Submit button label"
      response.should redirect_to(user_url(@user))
    end
    
    describe "edit scope" do
      it "should redirect to settings on success" do
        session[:user_id] = @user.id
        @user.should_receive(:update_attributes).and_return(true)
        @controller.should_not_receive(:render)
        post :update, :user_id => @user.id
        response.should redirect_to(scope_url(@user, :scope => 'settings'))
      end
      
      it "should render edit template on failure" do
        session[:user_id] = @user.id
        @user.should_receive(:update_attributes).and_return(false)
        @controller.should_receive(:render).with({:template => 'users/profiles/edit'})
        post :update, :user_id => @user.id
        response.should be_success
        flash[:warning].should == "There was a problem saving your account."
      end
    end
    
    describe "settings scope" do
      it "should redirect to congratulations on success" do
        pending
        session[:user_id] = @user.id
        @user.should_receive(:update_attributes).and_return(true)
        @controller.should_not_receive(:render)
        lambda {
          post :update, :user_id => @user.id, :scope => 'settings'
        }.should raise_error 
        # TODO Implement congratulations action
        # response.should redirect_to(scope_url(@user, :scope => 'settings'))
      end
      
      it "should render edit template on failure" do
        session[:user_id] = @user.id
        @user.should_receive(:update_attributes).and_return(false)
        @controller.should_receive(:render).with({:template => 'users/profiles/settings'})
        post :update, :user_id => @user.id, :scope => 'settings'
        response.should be_success
        flash[:warning].should == "There was a problem saving your account."
      end
    end
  end
end
