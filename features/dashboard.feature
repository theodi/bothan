Feature: Dashboard Interactions

  Scenario: Create a named dashboard
    Given I am logged in as "foo" with "bar"
    And there is a metric in the database with the name "membership-count"
    And there is a metric in the database with the name "membership-cost"
    When I go to "create dashboard"
    Then I should see "Create Dashboard" within "row"
#    When I fill in "test" for "title" within "form"
    When I populate a field "dashboard-title" with "test"
    Then show me the page
#    And I choose "membership-coverage" within "metric"
#    And I press "post-dashboard" within "form-group"
    # above not working because dud
    And I select "membership-coverage" from field "dashboard[metrics]" in the table "dashboard"
    And I click the button "post-dashboard"

    

  Scenario: Create a 2 * 2 grid dashboard
    pending
    #  AND I should see number of rows value 3
    #  AND I should see number of cols value 3