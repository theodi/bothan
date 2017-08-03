Feature: Dashboard Interactions


#  Scenario: create a named dashboard - capybara failing
#    Given I am logged in as "foo" with "bar"
#    Given there is a metric in the database with the name "membership-count"
#    Given there is a metric in the database with the name "membership-cost"
#    When I go to "create dashboard"
#    Then I should see "Create Dashboard" within "row"
##    When I fill in "test" for "title" within "form"
#    When I populate a field "dashboard-title" with "test"
#    Then show me the page
##    And I choose "membership-coverage" within "metric"
##    And I press "post-dashboard" within "form-group"
#    # above not working because dud
#    And I select "membership-coverage" from field "dashboard[metrics]" in the table "dashboard"
#    And I click the button "post-dashboard"

  @javascript
  Scenario: create a named dashboard, webkit

    Given I login with user: "foo" and pwd: "bar" and visit dashboards
    Then I should see "Create Dashboard" within "row"
    When I populate a field "dashboard-title" with "test"
    When I populate a field "slug" with "test"
    Then show me the page
    And I select "dashboard-0" from field "dashboard[metrics][0][name]" in the table "dashboard"
    And I select "dashboard-0" from field "dashboard[metrics][1][name]" in the table "dashboard"
    And I select "dashboard-0" from field "dashboard[metrics][2][name]" in the table "dashboard"
    And I select "dashboard-0" from field "dashboard[metrics][3][name]" in the table "dashboard"
    And I select "dashboard-0" from field "dashboard[metrics][4][name]" in the table "dashboard"
    And I select "dashboard-0" from field "dashboard[metrics][5][name]" in the table "dashboard"
    And I select "dashboard-0" from field "dashboard[metrics][6][name]" in the table "dashboard"
    And I select "dashboard-0" from field "dashboard[metrics][7][name]" in the table "dashboard"
    And I select "dashboard-0" from field "dashboard[metrics][8][name]" in the table "dashboard"
    And I click the button "post-dashboard"
    Then the current URL path is /dashboards/test

  Scenario: Create a 2 * 2 grid dashboard
    pending
    #  AND I should see number of rows value 3
    #  AND I should see number of cols value 3