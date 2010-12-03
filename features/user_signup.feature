Feature: User signup
  In order to use The Hype website
  As a visitor
  I want to be able to signup
  
  Scenario: Signing up
    Given I go to the signup page
     When I fill in "Username" with "Bobby"
      And I fill in "First name" with "Bob" 
      And I fill in "Last name" with "Dog" 
      And I fill in "Password" with "secret666" 
      And I fill in "Confirm" with "secret666" 
      And I fill in "Email" with "bob@dog.com" 
      And I select "1964" from "Date of birth"
      And I select "Eastern Time (US & Canada)" from "Time zone"
      And I select "Male" from "Gender"
      And I press "new-user-submit"
      Then user should exist with email: "bob@dog.com" 
      Then I should be on the user's edit favorites page
      And I should see "Thank you for signing up! Please fill in the rest of your profile data."

    
