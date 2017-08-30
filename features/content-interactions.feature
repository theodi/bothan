Feature: Authenticated HTML User Interactions

Scenario: un-authenticated user
    Given I authenticate as the user "foo" with the password "bar"
    When I go to "login"
    Then I should see "Authentication Required" within "body"

  Scenario: basic authenticated user
    Given I am logged in as "foo" with "bar"
    When I go to "login"
    Then I should not see "Authentication Required" within "body"
    Then I should see "Current Metrics" within "col-md-6"

  Scenario: dashboard HTML access
    Given I am logged in as "foo" with "bar"
    When I go to "create dashboard"
    Then I should see "Create Dashboard" within "row"

  @javascript
  Scenario: display admin functions for metrics when logged in
  pending
#    Given I am logged in as "foo" with "bar"
#    When I go to "the home page"
#    Then I should see a table of metrics
#    And I should see delete endpoint
#    And I should see edit metadata

  @javascript
  Scenario: delete an existing metric
    pending
#    Given I am logged in as "foo" with "bar" and I navigate to the home page
#    And there is a metric in the database with the name "kill me"
#    And I click the hyperlink delete
#    Then there should be no more metric
#    And the homepage should display no metrics