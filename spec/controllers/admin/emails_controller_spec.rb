require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::EmailsController do
  fixtures :users  
  
  before(:all) do
    EmailTemplate.default_url_options[:host] = 'test.host'
  end
  after(:all) do
    EmailTemplate.default_url_options[:host] = nil
  end
  
  before(:each) do
    login_as(:josh)
  end

  describe "GET 'index'" do
    it "should be successful" do
      EmailTemplate.should_receive(:find).with(:all)
      get 'index'
      response.should be_success
    end
  end

  describe "GET 'edit'" do
    it "should be successful" do
      EmailTemplate.should_receive(:find).with('1')
      get 'edit', :id => '1'
      response.should be_success
    end
    
  end

  describe "GET 'show'" do
    it "should be successful" do
      EmailTemplate.should_receive(:find).with('1')
      get 'show', :id => '1'
      response.should be_success
    end
  end

  describe "POST 'update'" do
    before do
      @email = Factory(:email_template)
    end
    
    it "should be successful" do
      post :update, :id => @email.id, :email_template => { :body => 'abc', :name => 'booohoo' }
      response.should redirect_to(admin_emails_url)
    end
    
    it "not update email name" do
      post :update, :id => @email.id, :email_template => { :body => 'abc', :name => 'booohoo' }

      @email.reload
      @email.name.should_not == 'booohoo'
      @email.body.should == 'abc'

      flash[:notice].should == "Successfully updated email template"
      response.should redirect_to(admin_emails_url)
    end
    
    it "should handle error in email update" do
      post :update, :id => @email.id, :email_template => { :body => '', :name => 'booohoo' }

      flash[:error].should == "Unable to update email template"
      response.should render_template('edit')
    end
  end
end
