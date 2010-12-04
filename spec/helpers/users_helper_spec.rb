require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe UsersHelper do
  
  #Delete this example and add some real ones or delete this file
  it "should be included in the object returned by #helper" do
    included_modules = (class << helper; self; end).send :included_modules
    included_modules.should include(UsersHelper)
  end

 
  describe "#complete_it_destination_path" do
    before(:each) do
      @current_user = Factory(:user, :profile => Factory(:profile))
      helper.stub(:current_user).and_return(@current_user)
    end
    
    it "should respond to #complete_it_destination_path" do
      helper.should respond_to(:complete_it_destination_path) 
    end
  
    it "should lead to step 2 when at least one of them is not set" do
      ItemCategory.stub(:count).and_return(3)
      @current_user.stub(:top).and_return(%w[first_item third_item])
      helper.complete_it_destination_path.should == edit_user_favorites_path(@current_user)
    end
    
    describe "after completion of top hyped" do
      before(:each) do
        ItemCategory.stub(:count).and_return(3)
        Essential.stub(:essential_categories).and_return(%w[first_category second_category third_category])
        @current_user.stub(:top).and_return(%w[first_item second_item third_item])
        
        @completed_attributes = {
          :country => "Spain",
          :city  => "Barcelona",
          :interest_list => "Being a dad",
          :trusted_brand_list => "Microsoft",
          :job => "developer",
          :about_me => "Happy go lucky developer dad.",
          :education_level => Factory(:education_level)
        }
        
      end
      
      it "should lead to step 3 when at least one field is blank" do
        @current_user.stub(:top).and_return(%w[first_item second_item third_item])
        @current_user.stub(:essentials_count).and_return(3)
        
        @completed_attributes.keys.each do |attribute_name|
          attributes = @completed_attributes
          attributes.delete(attribute_name)
          @current_user.profile.update_attributes(attributes)
          @current_user.reload
          helper.complete_it_destination_path.should == edit_user_profile_path(@current_user)
        end
      end
      
      
      it "should lead to step 3 when at least one essential is not set" do
        @current_user.stub(:top).and_return(%w[first_item second_item third_item])
        @current_user.profile.update_attributes(@completed_attributes)
        
        @current_user.stub(:essentials_count).and_return(2)
        
        helper.complete_it_destination_path.should == edit_user_profile_path(@current_user)
      end
      
      describe "after step 2" do
        
        before(:each) do
          @current_user.stub(:top).and_return(%w[first_item second_item third_item])
          @current_user.stub(:essentials_count).and_return(3)
          @current_user.profile.update_attributes(@completed_attributes)
        end
        
        it "should lead to step 3 when avatar is not set" do
          @current_user.profile.attachment_for(:avatar).stub(:original_filename).and_return(nil)
          helper.complete_it_destination_path.should == scope_path(@current_user, :scope => 'settings')
        end
        
        describe "after step 3" do
          it "should lead to congratulations" do
            @current_user.profile.attachment_for(:avatar).stub(:original_filename).and_return("avatar.png")
            helper.complete_it_destination_path.should == scope_path(@current_user, :scope => 'congrats')
          end
        end
      end
    end
  
  end
  context "#more_less" do
    it 'renders about me without any class when < 150 chars' do
      text = ('x'*9+' ')*15
      helper.more_less(text).should match text
    end
    context "text larger than 150 chars" do
      before :each do
        @first_part = ('x'*9+' ')*15
        @second_part = ('y'*9+' ')*15 
        @text = @first_part + @second_part 
      end
      it 'returns second portion of text wrapped in span with class' do
        helper.more_less(@text).should match "<span class=\"more\">#{@second_part}</span>" 
      end
      it 'shows first portion of text' do
        helper.more_less(@text).should match @first_part
      end
      it 'shows ellipse' do
        helper.more_less(@text).should match "<span class=\"ellipse\">... </span>"
      end
    end
  end
  
  context "#split_by_length" do

    it "returns the array with same word when length is short enough" do
      helper.split_by_length("word", 4).should == ["word"] 
    end

    it "returns two words when lenght at most twice as large" do
      helper.split_by_length("word", 2).should == ["wo", "rd"] 
    end

    it "leaves last word with length less than required" do
      helper.split_by_length("words", 2).should == ["wo", "rd", "s"] 
    end

  end
  context "#split_words_by_length" do
    it "splits one large word" do
      helper.split_words_by_length("0123456789", 3).should == "012 345 678 9"
    end
  end


end
