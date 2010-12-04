require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ItemComment do

  describe 'conversation members' do
    fixtures :users
    fixtures :profiles
    
    it 'should have conversation members' do
      i1 = Item.make(:user_id => users(:quentin).id)

      root1 = i1.comments.build(:user_id => users(:aaron).id)      
      middle1 = create_child_comment(i1, users(:josh), root1)
      child1 = create_child_comment(i1, users(:quentin), middle1)
      middle1b = create_child_comment(i1, users(:josh), root1)
      
      root2 = ItemComment.make(:item_id => i1.id, :user_id => users(:quentin).id)
      middle2 = create_child_comment(i1, users(:aaron), root2)
      child2 = create_child_comment(i1, users(:josh), middle2)
      
      child1.conversation_members.size.should == 2
      child1.conversation_members.first.login = 'aaron'
      child1.conversation_members[1].login = 'josh'
      
      middle1b.conversation_members.size.should == 3
      middle2.conversation_members.size.should == 2 
    end
    
  end
  
  def create_child_comment(item, user, parent)
    child = item.comments.build(:user_id => user.id)
    child.parent = parent
    child.save
    parent.save
    child
  end
end
