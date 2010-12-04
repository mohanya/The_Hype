Feature: Static pages
  In order to learn more about The Hype
  As a curious user
  I want to be able to see all static pages
  
Scenario: About page
   When go to the about page
   Then I should see "Reasons to join"
   And I should see "How to use the site"

Scenario: Langing page
   And go to the home page
   Then I should see "Log In"
   And I should not see "Items"
   When I am logged in
   And go to the home page
   Then I should not see "Log In"
   And I should see "Items"
