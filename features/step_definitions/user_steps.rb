Given /^beta invites are off$/ do
  SiteSetting.first.update_attribute(:beta_invites, false)
end

Given (/^#{capture_model} is activated$/) do |name|
  model = model(name)
  #raise "#{name} #{find_model(name).map(&:email).join(',')}"
  model.activate!
  model.should be_active
end
Given(/^I am logged in as "([^"]*)" with "([^"]*)"$/) do |username_or_email, password|
  steps %Q{
    Given I go to the login page
    Given I fill in "Username or email" with "#{username_or_email}"
    Given I fill in "Password" with "#{password}"
    Given I press "sign-in-button"  
    Then I should be on the homepage
    Then I should see "Logged in successfully"
  }
end

Given(/^(?:|I am )logged in$/) do
  steps %Q{
    Given the following users exist:
        | email            | password  | password_confirmation |
        | billy@pocket.com | secret666 | secret666             |
    Given the user is activated
    Given I am logged in as billy@pocket.com/secret666
  }
end

Given(/^#{capture_model}'s #{capture_model} has following attributes:$/) do |parent, child, fields_table|
  child_model = model(parent).send(child)
  child_model.update_attributes(fields_table.hashes.first).should == true
end
