Feature: test if any UI testing possible

  Background: HTML not JSON
    Given I send and accept HTML

    Scenario: main page
      When I go to "the home page"
      Then show me the page