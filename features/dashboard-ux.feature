Feature: Dashboard UX

  Background: Given I send and accept HTML
    And there is a metric in the database with the name "membership-coverage"
    And it has a time of "2013-12-25T15:00:00+00:00"
    And it has a value of:
      """
      {"health":0.34,"telecoms":0.34,"energy":0.34}
      """

    Scenario: Create a Dashboard
      Given I authenticate as the user "foo" with the password "bar"
      And there is a metric in the database with the name "membership-coverage"
      And I send a GET request to "dashboards/new"
#      And I go to "dashboards/new" #doesn't work - uncertain if anything in web_steps works
      Then I should see a form
      # TODO steps needed to check for existence of Box Colour, Text Colour, Width, Height AKA fields present PRIOR to metric select
      And I choose "membership-coverage" within "metric"
      Then the form should have a field "title"
      # ensure that selected metric exclusive fields have been populated