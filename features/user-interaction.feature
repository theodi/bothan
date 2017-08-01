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
    pending

  Scenario: dashboard HTML access
    pending

