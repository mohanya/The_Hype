require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::JobsController do
  fixtures :users
  
  before(:all) do
    User.default_url_options[:host] = 'test.host'
  end
  after(:all) do
    User.default_url_options[:host] = nil
  end
  
  before(:each) do
    login_as(:josh)
  end


  describe "GET 'index'" do
    it "should be successful" do
      get 'index'
      response.should be_success
    end
  end
  
  describe "with an ID" do
    
    before(:each) do
      @job = Factory(:delayed_job)
    end
    
    describe "GET 'show'" do
      it "should be successful" do
        get 'show', :id => @job
        response.should be_success
      end
    end

    describe "GET 'destroy'" do
      it "should be successful" do
        lambda do
          delete 'destroy', :id => @job
          response.should redirect_to(admin_jobs_url)
        end.should change(Delayed::Job, :count)
      end
    end
    
  end

end
