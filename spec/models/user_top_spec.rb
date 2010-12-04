require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe UserTop do
  fixtures(:users)

  before do
    UserTop.destroy_all
    Item.destroy_all
    ItemCategory.destroy_all

    @user = users('quentin')
    add_items
  end

  it "should create valid user_top" do
    ut = UserTop.make
    ut.should be_valid
    ut.save.should == true
  end
  it "should require user_id" do
    ut = UserTop.make_unsaved(:user_id => nil)
    ut.should_not be_valid
    ut.save.should == false
  end

  it "should require item_id" do
    ut = UserTop.make_unsaved(:item_id => nil)
    ut.should_not be_valid
    ut.save.should == false
  end

  it "should create new top items" do
    items = {'product' => 'ipod', 'music-artist' => "porter-ricks"}

    UserTop.create_or_update(items, @user)
    UserTop.all.length.should == 2
  end

  it "should update and add top item in specific category" do
    items = {'product' => 'ipod'}

    UserTop.create_or_update(items, @user)
    UserTop.all.length.should == 1
    UserTop.find_by_item_id('ipod').should_not be_nil

    items = {'product' => 'zen', 'music-artist' => 'porter-ricks'}

    UserTop.create_or_update(items, @user)

    UserTop.find_by_item_id('ipod').should be_nil
    UserTop.find_by_item_id('zen').should_not be_nil
    UserTop.find_by_item_id('porter-ricks').should_not be_nil
    UserTop.all.length.should == 2
  end




  it "should remove ALL items" do
    items = {'product' => 'zen', 'music-artist' => "porter-ricks"}
    UserTop.create_or_update(items, @user)
    UserTop.all.length.should == 2

    items = {'product' => '', 'music-artist' => ""}
    UserTop.create_or_update(items, @user)
    UserTop.all.length.should == 0
  end

  it "should NOT create 2 the same tops" do
    2.times do
      items = {'product' => 'ipod'}

      UserTop.create_or_update(items, @user)
      UserTop.all.length.should == 1
      UserTop.all.last.item_id.should == 'ipod'
    end
  end

end
