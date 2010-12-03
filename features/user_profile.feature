Feature: User profile 
  In order to see various users' information
  As a user
  I want to be able to visit other users profiles and edit mine
  
  Scenario: Visiting own profile
    Given the following users exist:
        | email            | password  | password_confirmation |
        | billy@pocket.com | secret666 | secret666             |
      And the user is activated
      And that user's profile has following attributes:
        | first_name | last_name |
        | Billy      | Pocket    |
      And I am logged in as billy@pocket.com/secret666
     When I go to that user's page
     Then I should see "Billy Pocket" within "h1"
     