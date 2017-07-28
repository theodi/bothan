Feature: test if any UI testing possible

  Background: HTML not JSON
    Given I send and accept HTML
    And I authenticate as the user "foo" with the password "bar"

    Scenario: main page
      Given I authenticate as the user "foo" with the password "bar"
      When I go to "the home page"
      Then show me the page