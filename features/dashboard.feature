Feature: Dashboard Interactions

  @javascript
  Scenario: create a named dashboard with default row*column dimensions

    Given I login with user: "foo" and pwd: "bar" and visit "dashboards/new"
    Then I should see "Create Dashboard" within "row"
    And I populate a field "dashboard-title" with "test"
    And I populate a field "slug" with "test"
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
    And the dashboard "test" has "9" panels

  @javascript
  Scenario: do not create empty dashboards
    Given I login with user: "foo" and pwd: "bar" and visit "dashboards/new"
    Then I should see "Create Dashboard" within "row"
    When I populate a field "dashboard-title" with "test"
    When I populate a field "slug" with "test"
    And I click the button "post-dashboard"
    Then I should see "metrics can't be blank" within "body"

  @javascript
  Scenario: Create a 2 * 2 grid dashboard
    Given I login with user: "foo" and pwd: "bar" and visit "dashboards/new"
    And I populate a field "dashboard-title" with "test"
    And I populate a field "slug" with "test"
    Then I populate a field "rows" with "2"
    Then I populate a field "columns" with "2"
    And I select "dashboard-0" from field "dashboard[metrics][0][name]" in the table "dashboard"
    And I select "dashboard-0" from field "dashboard[metrics][1][name]" in the table "dashboard"
    And I select "dashboard-0" from field "dashboard[metrics][2][name]" in the table "dashboard"
    And I select "dashboard-0" from field "dashboard[metrics][3][name]" in the table "dashboard"
    And I click the button "post-dashboard"
    Then the dashboard "test" has "4" panels