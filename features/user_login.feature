Feature: User signup
  In order to use The Hype website
  As a visitor
  I want to be able to signup
  
  Scenario: Sign up of activated user using email
    Given user exists with email: "bob@dog.com", password: "secret666", password_confirmation: "secret666"
      And the user is activated 
      And I go to the login page
     When I fill in "Username or email" with "bob@dog.com"
      And I fill in "Password" with "secret666"
      And I press "sign-in-button"
     Then I should be on the homepage
      And I should see "Logged in successfully"
     