Feature:

  Scenario: main page
  #  Given I authenticate as the user "foo" with the password "bar"
    When I visit the homepage
    Then show me the page


  Scenario: un-authenticated user
    Given I send and accept HTML
    And I authenticate as the user "foo" with the password "bar"
    # re-using code that metadata.feature uses to check if API auth will suffice for HTML interactions
    When I go to "login"
    Then I should see "Authentication Required" within "body"
#    Then show me the page

  Scenario: basic authenticated user
    Given I send and accept HTML
#    And I authenticate as the user "foo" with the password "bar"
    When I am logged in as "foo" with "bar"
    When I go to "login"
    Then I should not see "Authentication Required" within "body"
    Then I should see "Current Metrics" within "col-md-6"

  Scenario: dashboard HTML access
    Given I send and accept HTML
    And I am logged in as "foo" with "bar"
    When I go to "dashboard"
    Then I should see "Create Dashboard" within "row"
#    Then show me the page
