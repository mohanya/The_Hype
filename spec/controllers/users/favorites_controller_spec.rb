require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Users::FavoritesController do
  fixtures(:users)
  fixtures(:profiles)

  before do
    Item.destroy_all
    ItemCategory.destroy_all
    login_as(:quentin)
    @user = users(:quentin)

  end


  it "should have categories index" do
    get(:edit, :user_id => @user.id)
    response.should be_success
    assigns(:categories).should_not be_nil
  end

  it "should render template for wizard" do
    get(:edit, :user_id => @user.id)
    response.should be_success
    response.should render_template('edit_for_wizard.html.haml')
  end

  it "should render template for profile" do
    get(:edit, :user_id => @user.id, :from => "profile")
    response.should be_success
    response.should render_template('edit_for_profile.html.haml')
  end

  it "should have hash with top items objects" do
    add_items

    items = {'product' => 'zen', 'artist' => "porter-ricks"}
    UserTop.create_or_update(items, @user)

    get(:edit, :user_id => @user.id)

    response.should be_success
    assigns(:items).should_not be_nil

    assigns(:items).has_key?('product').should == true
    assigns(:items)['product'].should == UserTop.find_by_item_id('zen')

    assigns(:items).has_key?('artist').should == true
    assigns(:items)['artist'].should == UserTop.find_by_item_id('porter-ricks')
  end

  it "should redirect to profile step" do
    post(:update, :user_id => @user.id)

    flash[:error].should be_nil
    response.should redirect_to(edit_user_profile_path(@user))
  end

  it "should redirect to homepage if param ref=homepage is provided" do
    post(:update, :user_id => @user.id, :ref => "homepage")

    flash[:error].should be_nil
    response.should redirect_to('/')
  end

  it "should redirect to homepage if param ref=homepage is provided" do
    post(:update, :user_id => @user.id, :ref => "homepage")

    flash[:error].should be_nil
    response.should redirect_to('/')
  end

  it "should display error message" do
    UserTop.should_receive(:create_or_update).and_raise(StandardError.new)

    post(:update, :user_id => @user.id)
    flash[:notice].should == "StandardError"
    response.should redirect_to(edit_user_profile_path(@user))
  end

end
