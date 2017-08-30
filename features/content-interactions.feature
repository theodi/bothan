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

  Scenario: display admin functions for metrics when logged in
    Given I am logged in as "foo" with "bar"
    And there is a metric in the database with the name "delete me"
    When I go to "the home page"
    Then I should see "metric" within "table"
    And I should see "delete" within "tr"
    And I should see "edit metadata" within "tr"

  Scenario: delete an existing metric
    Given I am logged in as "foo" with "bar"
    And there is a metric in the database with the name "delete-me"
    When I go to "the home page"
    When I click the button "delete-metric"