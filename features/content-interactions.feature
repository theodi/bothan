Feature: Authenticated HTML User Interactions

Scenario: un-authenticated user
    Given I authenticate as the user "foo" with the password "bar"
    # re-using code that metadata.feature uses to check if API auth will suffice for HTML interactions
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
