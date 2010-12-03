require File.dirname(__FILE__) + '/../spec_helper'

describe PagesController do
  
  it "GET index should redirect to the 'landing' page" do
    get :index
    response.should render_template("pages/landing.html.haml")
  end


  describe "GET 'show'" do
    
    
    it "without an id" do
      get :index
      response.should render_template("pages/landing")
      response.should be_success
    end
  
    it "with an id" do
      get :show, :id => "contact"
      response.should render_template("pages/contact")
      response.should be_success
    end
    
    it "should raise an error if the template is missing" do
      lambda do
        get 'show', :id => "crazy_uncreated_id"
      end.should raise_error
    end
  end
  
  
end
