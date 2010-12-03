Feature: User signup
  In order to use navigate The Hype website
  As a logged in user
  I want to be able to see and use the main menu
  
@javascript
Scenario: Showing the menu
  Given I am logged in
   And go to the home page
   When I follow "user_profile_link"
   Then I should see "Inbox"  
