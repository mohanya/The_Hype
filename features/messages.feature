Feature: Messages
  In order to contact another user
  As a user
  I want to be able to send and read messages
  
  Background:
    Given the following users exist:
        | user  | email              | password  | password_confirmation |
        | gaga  | lady@gaga.com      | secret666 | secret666             |
        | billy | billy@pocket.com   | secret666 | secret666             |
        | robin | robin@williams.com | secret666 | secret666             |
      And a user: "billy"'s profile has following attributes:
        | first_name | last_name |
        | Billy      | Pocket    |
      And a user: "gaga"'s profile has following attributes:
        | first_name | last_name |
        | Lady       | Gaga      |
      And a user: "robin"'s profile has following attributes:
        | first_name | last_name |
        | Robin      | Williams  |
      And a user: "billy" is activated
      And a user: "robin" is activated
      And a user: "gaga" is activated
    
  Scenario: No messages page displays correct information
    Given I am logged in as "billy@pocket.com" with "secret666"
     When I go to the messages page
     Then I should see "You have no messages"
  
  Scenario: Common elements displays correctly
    Given I am logged in as "billy@pocket.com" with "secret666"
     When I go to the messages page
     Then I should see "Inbox" within "h1"
      And I should see "Messages, Comments and Notices" within "h3"

     And I should see "#messages-header" element
     And I should see "button.new-message" element within "#messages-header"
     
     And I should see ".pagination" element within "#messages-header"
     And I should see "a.next" element within "#messages-header .pagination"
     And I should see "a.previous" element within "#messages-header .pagination"

     And I should see ".messages" element

     And I should see "#messages-footer" element
     And I should see ".pagination" element within "#messages-footer"
     And I should see "a.next" element within "#messages-footer .pagination"
     And I should see "a.previous" element within "#messages-footer .pagination"
     
  Scenario: Navigation from settings
    Given I am logged in as "billy@pocket.com" with "secret666"
    #      And I am on the user's edit password page
    #When I follow "Inbox" within "#submenu"
    #Then I should be on the messages page
  
  
  Scenario: Display of messages without pagination
    Given I am logged in as "lady@gaga.com" with "secret666"
    Given the following messages exists:
        | sender         | receiver         |
        | user: "billy"  | user: "gaga"     |
        | user: "billy"  | user: "gaga"     |
        | user: "billy"  | user: "gaga"     |
     When I go to the messages page
     Then I should see 3 messages

  Scenario: Subjects are displayed and lead to message pages.
    Given I am logged in as "lady@gaga.com" with "secret666"
    Given the following messages exists:
        | sender         | message        | receiver         | subject  |
        | user: "billy"  | first          | user: "gaga"     | Hello    |
        | user: "billy"  | second         | user: "gaga"     | Hi again |
        | user: "billy"  | third          | user: "gaga"     | Bye      |
     When I go to the messages page
     # Then show me the page
     Then I should see "Hello" within ".message .subject"
      And I should see "Hi again" within ".message .subject"
      And I should see "Bye" within ".message .subject"
     When I follow "Hi again" within ".message .subject"
     Then I should be on the message: "second"'s page

  Scenario: Message bodies are trucated to 50 characters
    Given I am logged in as "lady@gaga.com" with "secret666"
    Given the following messages exists:
        | sender         | receiver         | body                                                        |
        | user: "billy"  | user: "gaga"     | I just wanted to say hi. Are you really that famous person? |
        | user: "billy"  | user: "gaga"     | Are you there?                                              |
        | user: "billy"  | user: "gaga"     | Ok. You don't want to write anything? Fine! We're through!  |
     When I go to the messages page
     Then show me the page
     Then I should see "I just wanted to say hi. Are you really that fa..." within ".message .truncated-body"
      And I should see "Are you there?" within ".message .truncated-body"
      And I should see "Ok. You don't want to write anything? Fine! We'..." within ".message .truncated-body"
    
  Scenario: Dates are displayed properly 
    Given I am logged in as "lady@gaga.com" with "secret666"
    Given the following messages exists:
        | sender         | receiver         | created_at |
        | user: "billy"  | user: "gaga"     | 2010-10-28 |
        | user: "billy"  | user: "gaga"     | 2010-11-13 |
        | user: "billy"  | user: "gaga"     | 2010-12-16 |
     When I go to the messages page
     Then I should see "October 28, 2010" within ".message .date"
      And I should see "November 13, 2010" within ".message .date"
      And I should see "December 16, 2010" within ".message .date"

  Scenario: Sender name is displayed properly and it leads to profile page
    Given I am logged in as "lady@gaga.com" with "secret666"
    Given the following messages exists:
        | sender         | receiver         |
        | user: "billy"  | user: "gaga"     |
        | user: "robin"  | user: "gaga"     |
     When I go to the messages page
     Then I should see "Billy Pocket" within ".message .sender .name"
      And I should see "Robin Williams" within ".message .sender .name"
     When I follow "Billy Pocket" within ".message .sender .name" 
     Then I should be on user: "billy"'s page

  Scenario: Message removal
    Given I am logged in as "lady@gaga.com" with "secret666"
      And the following messages exists:
      | message | sender         | receiver         | subject |
      | first   | user: "robin"  | user: "gaga"     | hi      |
      | second  | user: "billy"  | user: "gaga"     | hello   |
      | third   | user: "billy"  | user: "gaga"     | bye     |
     When I go to the messages page
      And I follow "Remove" within message: "second"'s partial
     Then I should see message: "first"'s partial
      And I should see message: "third"'s partial
      And I should see 2 messages
      And the message should not exist with subject: "hello" 

      @wip
  Scenario: Only received messages are visible
    Given I am logged in as "lady@gaga.com" with "secret666"
      And the following messages exists:
      | message | sender         | receiver         | subject |
      | first   | user: "robin"  | user: "gaga"     | hi      |
      | second  | user: "gaga"  | user: "robin"     | hello   |
     When I go to the messages page
     Then I should see message: "first"'s partial
      And I should see 1 messages

  @wip @javascript
  Scenario: New message popup opened using new message button
     Given I am logged in as "billy@pocket.com" with "secret666"
     And I am on the messages page
     Then show me the page
     When I follow "new-message-button" within "#messages-header"
     Then I should be on the messages page
      And I should see "#new-message-popup" element
      And I should see "Type in the name of user or email address" within "#new-message-popup"
      And the "To:" field within "#new-message-popup" should contain ""
      And the "Subject:" field within "#new-message-popup" should contain ""
      And the "Message:" field within "#new-message-popup" should contain ""
      And I should see "button.send-message" element within "#new-message-popup"
      And I should see "Cancel" within "#new-message-popup" 

  @wip @javascript
  Scenario: New message popup opened using reply button
    Given I am logged in as "lady@gaga.com" with "secret666"
      And the following messages exists:
      | message | sender         | receiver         | subject |
      | first   | user: "billy"  | user: "gaga"     | hi      |
     And I am on the messages page
     Then show me the page
     When I follow "Reply" within message: "first"'s partial
     Then I should be on the messages page
      And I should see "#new-message-popup" element
      And I should not see "Type in the name of user or email address" within "#new-message-popup"
      And the "To:" field within "#new-message-popup" should contain "Billy Pocket"
      And the "Subject:" field within "#new-message-popup" should contain "Re: hi"
      And the "Message:" field within "#new-message-popup" should contain ""
      And I should see "button.send-message" element within "#new-message-popup"
      And I should see "Cancel" within "#new-message-popup"
      
  @javascript
  Scenario: New message popup opened using New message button
    Given I am logged in as "lady@gaga.com" with "secret666"
      And I am on the user: "gaga"'s page
     Then show me the page
     #     When I follow "new-message-button" within "#messages-header"
     Then I should be on the messages page
      And I should see "#new-message-popup" element
      And I should not see "Type in the name of user or email address" within "#new-message-popup"
      And the "To:" field within "#new-message-popup" should contain "Billy Pocket"
      And the "Subject:" field within "#new-message-popup" should contain ""
      And the "Message:" field within "#new-message-popup" should contain ""
      And I should see "button.send-message" element within "#new-message-popup"
      And I should see "Cancel" within "#new-message-popup"
      
#TODO:
  Scenario: Billy opens new message popup but is too shy to send a message
    Given I am logged in as "billy@pocket.com" with "secret666"
      And I am on the messages page
     When I press "#new-message" within "#messages-header"
     Then I should be on the messages page
      And I should see ".new-message-popup"

     
     When I follow "Cancel" within "#new-message-popup"
     Then I should be on the messages page
      And I should not see "#new-message-popup"
      And user: "billy" should have 0 sent_messages


  Scenario: Gaga clicks reply button but decides not to send message
    Given I am logged in as "lady@gaga.com" with "secret666"
      And I am on the messages page
      And the following messages exists:
        | sender         | message        | receiver         | subject  |
        | user: "billy"  | first          | user: "gaga"     | Hello    |
     When I press ".reply" within message: "first" partial
     Then I should see "#new-message-popup"
      
      And I should not see "Type in the name of user or email address"
      And the "To:" field within "#new-message-popup" should contain "Billy Pocket"
      And the "Subject:" field within "#new-message-popup" should contain "Re: Hello"
      And the "Message:" field within "#new-message-popup" should contain ""
      And I should see "button.send-message" element within "#new-message-popup"
      And I should see "Cancel" within "#new-message-popup"

     When I press ".send-message" within "#new-message-popup"
     Then I should be on the messages page
      And I should not see "#new-message-popup"
      And user: "gaga" should have 0 sent_messages

  Scenario: Billy successfully sends a message to Gaga
  Scenario: Gaga successfuly replies to a message
  Scenario: Billy successfully replies to Gaga's reply
  Scenario: Billy tries to send a message but does not fill required fields
  Scenario: Billy is using autocomplete function to find receiver by name
  Scenario: Trying to send a message to anyone except followers or followees results in error message

