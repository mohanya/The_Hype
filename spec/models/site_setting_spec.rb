require File.dirname(__FILE__) + '/../spec_helper'

describe SiteSetting, "layouts" do
  it "should look for layouts in app/views/layouts" do
    Dir.should_receive(:new).with("app/views/layouts").and_return([])
    
    SiteSetting.layouts
  end

  it "should exclude dot, dotdot and partials in layouts directory" do
    dir = [".", "..", "_event.html.haml", "application.html.haml", "admin.html.haml"]
    Dir.should_receive(:new).with("app/views/layouts").and_return(dir)
    
    SiteSetting.layouts.should == ["application.html.haml", "admin.html.haml"]
  end
end