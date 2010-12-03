require 'spec_helper'

describe  Inbox::MessagesController do
  describe "routing" do
    it "recognizes and generates #index" do
      { :get => "/inbox/messages" }.should route_to(:controller => "inbox/messages", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/inbox/messages/new" }.should route_to(:controller => "inbox/messages", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/inbox/messages/1" }.should route_to(:controller => "inbox/messages", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/inbox/messages/1/edit" }.should route_to(:controller => "inbox/messages", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/inbox/messages" }.should route_to(:controller => "inbox/messages", :action => "create") 
    end

    it "recognizes and generates #update" do
      { :put => "/inbox/messages/1" }.should route_to(:controller => "inbox/messages", :action => "update", :id => "1") 
    end

    it "recognizes and generates #destroy" do
      { :delete => "/inbox/messages/1" }.should route_to(:controller => "inbox/messages", :action => "destroy", :id => "1") 
    end
  end
end
