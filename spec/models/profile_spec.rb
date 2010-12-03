require File.dirname(__FILE__) + '/../spec_helper'

describe Profile do
  fixtures :users
  
  before do
    template = Factory(:email_template)
    EmailTemplate.stub!(:find_by_name).and_return(template)
  end
  
  describe "hyper type" do
    it "contain 3 hyper types" do
      Profile.hyper_types.size.should == 3
    end
  end
 
  describe "validations and associations " do
    
    before(:each) do
      @profile = Profile.new
    end
    
    it "should allow maximum of 600 chars in about me" do
      words = "123456789 " * 60
      @profile.attributes = Factory.attributes_for(:profile, :about_me => words)
      @profile.should be_valid
      @profile.attributes = Factory.attributes_for(:profile, :about_me => words + 'a')
      @profile.should_not be_valid
      
    end
    
    describe "when assigned to user" do
      before(:each) do
        @profile.stub(:assigned_to_user?).and_return(true)
      end
      
      it "should not validate uniqueness of email" do
        @profile.should_not validate_uniqueness_of(:email)
      end
      
      it "should not validates presence of email" do
        @profile.should_not validate_presence_of(:email)
      end

      it "validates presence of gender" do
        @profile.attributes = Factory.attributes_for(:profile).reject{|k,v| k.to_sym == :gender}
        @profile.should_not be_valid
      end

      it "validates presence of birth date, first name and last name" do
        @profile.should validate_presence_of(:birth_date)
        @profile.should validate_presence_of(:first_name)
        @profile.should validate_presence_of(:last_name)
      end
      
    end
    
    describe "while not assigned to user" do
      before(:each) do
        @profile.stub(:assigned_to_user?).and_return(false)
      end
      
      it "should validate uniqueness of email" do
        @profile.should validate_uniqueness_of(:email)
      end

      it "validates presence of email" do
        @profile.should validate_presence_of(:email)
      end

      it "should not validate presence of gender if assigned to user" do
        @profile.attributes = Factory.attributes_for(:profile).reject{|k,v| k.to_sym == :gender}
        @profile.should be_valid
      end

      it "should not validate presence of birth date, first name and last name" do
        @profile.should_not validate_presence_of(:birth_date)
        @profile.should_not validate_presence_of(:first_name)
        @profile.should_not validate_presence_of(:last_name)
      end
      
    end
    
    it "belongs to a user" do
      @profile.should belong_to(:user)
    end
    
    it "belongs to a referral" do
      @profile.should belong_to(:referral)
    end
    
  end
  
  describe "gender" do
    it "should provide gender values" do
      (Profile.genders - %w[Male Female]).should be_empty 
    end
    
    it "should modify is_male field on gender update" do
      profile = Factory.build(:profile, :gender => 'Female')
      lambda {
        profile.gender = "Male"
      }.should change(profile, :is_male?).from(false).to(true)
      lambda {
        profile.gender = "Female"
      }.should change(profile, :is_male?).from(true).to(false)
      lambda {
        profile.gender = "Unknown"
      }.should_not change(profile, :is_male?)
      
      lambda {
        profile.update_attribute(:gender, "Male")
      }.should change(profile, :is_male?).from(false).to(true)
      lambda {
        profile.update_attribute(:gender, "Female")
      }.should change(profile, :is_male?).from(true).to(false)
      lambda {
        profile.update_attribute(:gender, "Unknown").should == true
      }.should_not change(profile, :is_male?)
    end
    
    it "should get correct value depending on is_male attribute" do
      profile = Factory.build(:profile, :gender => 'Female')
      lambda {
        profile.is_male = true
      }.should change(profile, :gender).from('Female').to('Male')
      lambda {
        profile.is_male = false
      }.should change(profile, :gender).from("Male").to("Female")
    end
  end
  
  describe "handles referrals properly" do
  
    it "returns the referral properly" do
      referrer = create_profile
      referred = create_profile(:email => "josh@test.com", :first_name => "Josh", :referral => referrer)
      referred.referral.should == referrer
    end
    
  end
  
  describe "signup progress" do
    before(:each) do
      user = Factory(:user)#, :profile => Factory(:profile))
      @profile = user.profile # TODO: gender 
      @completed_attributes = {
        :country => "Spain",
        :city  => "Barcelona",
        :interest_list => "Being a dad",
        :trusted_brand_list => "Microsoft",
        :job => "developer",
        :about_me => "Happy go lucky developer dad.",
        :education_level => Factory(:education_level)
      }
      ItemCategory.stub(:count).and_return(3)
      Essential.stub(:essential_categories).and_return(%w[first_category second_category third_category])
    end
    
    it "should have 25% after signup" do
      @profile.user.should_receive(:top).and_return([])
      @profile.user.should_receive(:essentials_count).and_return(0)
      @profile.attachment_for(:avatar).should_receive(:original_filename).and_return(nil)
      @profile.signup_progress.should == 25
    end
    
    it "should get 5% for adding avatar" do
      @profile.user.should_receive(:top).and_return([])
      @profile.user.should_receive(:essentials_count).and_return(0)
      @profile.attachment_for(:avatar).should_receive(:original_filename).and_return("filename.png")
      @profile.signup_progress.should == 30
    end
    
    it "should have 100% when every field is completed" do
      @profile.update_attributes(@completed_attributes)
      @profile.user.should_receive(:top).and_return(%w[first_item second_item third_item])
      @profile.user.should_receive(:essentials_count).and_return(3)
      @profile.attachment_for(:avatar).should_receive(:original_filename).and_return("filename.png")
      @profile.signup_progress.should == 100
    end
    
    it "should have between 25% and 100% when one of fields is missing" do
      @profile.user.should_receive(:top).at_least(:once).and_return(%w[first_item second_item third_item])
      @profile.user.should_receive(:essentials_count).at_least(:once).and_return(3)
      @profile.attachment_for(:avatar).should_receive(:original_filename).at_least(:once).and_return("filename.png")
      @completed_attributes.keys.each do |attribute_name|
        attributes = @completed_attributes
        attributes.delete(attribute_name)
        @profile.update_attributes(attributes)
        @profile.signup_progress.should < 100
        @profile.signup_progress.should > 25
      end
      
    end
    it "should be 95% when avatar is missing" do
      @profile.user.should_receive(:top).and_return(%w[first_item second_item third_item])
      @profile.user.should_receive(:essentials_count).and_return(3)
      @profile.attachment_for(:avatar).should_receive(:original_filename).and_return(nil)
      @profile.update_attributes(@completed_attributes)
      @profile.signup_progress.should == 95
    end
    
    it "should have between 25% and 100% when one top hyped is missing" do
      @profile.user.should_receive(:top).twice.and_return(%w[first_item third_item])
      @profile.user.should_receive(:essentials_count).twice.and_return(3)
      @profile.attachment_for(:avatar).should_receive(:original_filename).twice.and_return("filename.png")
      @profile.update_attributes(@completed_attributes)
      @profile.signup_progress.should < 100
      @profile.signup_progress.should > 25
    end
    
    it "should have count each top hyped item when calculating percentage" do
      @profile.update_attributes(@completed_attributes)
      @profile.user.should_receive(:essentials_count).twice.and_return(3)
      @profile.attachment_for(:avatar).should_receive(:original_filename).twice.and_return("filename.png")
      @profile.user.should_receive(:top).and_return(%w[first_item])
      earlier_progress = @profile.signup_progress
      @profile.user.should_receive(:top).and_return(%w[first_item third_item])
      @profile.signup_progress.should > earlier_progress
    end
    
    
    it "should have between 25% and 100% when one of essentials is missing" do
      @profile.user.should_receive(:top).twice.and_return(%w[first_item second_item third_item])
      @profile.user.should_receive(:essentials_count).twice.and_return(2)
      @profile.attachment_for(:avatar).should_receive(:original_filename).twice.and_return("filename.png")
      @profile.update_attributes(@completed_attributes)
      @profile.signup_progress.should < 100
      @profile.signup_progress.should > 25
    end
    
    it "should have count each essential when calculating percentage" do
      @profile.update_attributes(@completed_attributes)
      @profile.user.should_receive(:top).twice.and_return(%w[first_item second_item third_item])
      @profile.attachment_for(:avatar).should_receive(:original_filename).twice.and_return("filename.png")
      @profile.user.should_receive(:essentials_count).and_return(1)
      earlier_progress = @profile.signup_progress
      @profile.user.should_receive(:essentials_count).and_return(2)
      @profile.signup_progress.should > earlier_progress
    end
  end
  
  describe "interests" do
    before(:each) do
      @profile = create_profile
    end
    
    it "should create list of one interest" do
      lambda {
        @profile.interest_list = "being a dad"
      }.should change(Interest, :count).by(1)
      @profile.interests.first.name.should == "being a dad"
      @profile.interests.first.pos.should == 1
      
    end
    
    it "should create ordered list of interests" do
      lambda {
        @profile.interest_list = "being a dad, parenting, hyping as hell"
      }.should change(Interest, :count).by(3)
      (@profile.interests.map { |interest| [interest.name, interest.pos] } - [["being a dad", 1], ["parenting", 2], ["hyping as hell", 3]]).should be_empty
    end
    
    it "should return interests ordered by pos" do
      [
        ["second", 2],
        ["third", 3],
        ["first", 1]
      ].each { |data| Interest.create(:name => data[0], :pos => data[1], :profile_id => @profile.id) }
      @profile.reload
      
      @profile.interests[0].name.should == "first"
      @profile.interests[0].pos.should == 1
      
      @profile.interests[1].name.should == "second"
      @profile.interests[1].pos.should == 2
      
      @profile.interests[2].name.should == "third"
      @profile.interests[2].pos.should == 3
    end
  end
  
  describe "trusted_brands" do
    before(:each) do
      @profile = create_profile
    end
    
    it "should create list of one trusted_brand" do
      lambda {
        @profile.trusted_brand_list = "apple"
      }.should change(TrustedBrand, :count).by(1)
      @profile.trusted_brands.first.name.should == "apple"
      @profile.trusted_brands.first.pos.should == 1
      
    end
    
    it "should create ordered list of trusted_brands" do
      lambda {
        @profile.trusted_brand_list = "apple, microsoft, nokia"
      }.should change(TrustedBrand, :count).by(3)
      (@profile.trusted_brands.map { |trusted_brand| [trusted_brand.name, trusted_brand.pos] } - [["apple", 1], ["microsoft", 2], ["nokia", 3]]).should be_empty
    end
    
    it "should return trusted_brands ordered by pos" do
      [
        ["second", 2],
        ["third", 3],
        ["first", 1]
      ].each { |data| TrustedBrand.create(:name => data[0], :pos => data[1], :profile_id => @profile.id) }
      @profile.reload
      
      @profile.trusted_brands[0].name.should == "first"
      @profile.trusted_brands[0].pos.should == 1
      
      @profile.trusted_brands[1].name.should == "second"
      @profile.trusted_brands[1].pos.should == 2
      
      @profile.trusted_brands[2].name.should == "third"
      @profile.trusted_brands[2].pos.should == 3
    end
  end
  
  
  it "should parse the email list" do
    list = Profile.parse_friends_email("Tom@test.com\r\nBob@test.com")
    list.should == ["Tom@test.com", "Bob@test.com"]
  end
  
  describe "processes email referral lists" do
    before(:each) do
      @profile = create_profile
      Profile.stub!(:send_referral_emails)
      ReferralMailer.stub!(:deliver_confirmation)
      ReferralMailer.stub!(:deliver_admin_confirmation)
    end
    
    it "should take a profile and add the referrals from the email list" do
      lambda do
        @profile.add_referrals("Tom@test.com\r\nBob@test.com", "Test")
      end.should change(Profile, :count).by(2)
    end
    
    it "should save the referral email address" do
      referrals = @profile.add_referrals("Tom@test.com", "Test")
      referrals.first.email.should == "Tom@test.com"
    end
    
  end
  
  describe "processes email lists and sends email" do
    before(:each) do
      @profile = create_profile
    end
    
    it "should email referrals" do
      referral1 = Factory(:profile, :referral => @profile)
      ReferralMailer.should_receive(:delay).with(:deliver_referral, referral1, "Test")
      ReferralMailer.should_receive(:delay).with(:deliver_confirmation, @profile)
      ReferralMailer.should_receive(:delay).with(:deliver_admin_confirmation, @profile, [referral1])
      Profile.send_referral_emails(@profile, [referral1], "Test")
    end
    
  end
  
  describe "handles profile data" do
    it "should return nil if first name and last name are not set" do
      profile = create_profile(:first_name => nil, :last_name => nil)
      profile.fullname.should be_nil
    end
    
    it "should return a string when calling fullname and first/last name are set" do
      profile = create_profile
      profile.fullname.should == "Joe Blow"
    end
  end
  
  protected
  
  def create_profile(options = {})  
    Factory(:profile, options)
  end
  
end
