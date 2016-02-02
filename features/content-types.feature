Feature: Content Types

  Scenario: GET root with HTML content type
    Given I send and accept HTML
    When I send a GET request to "/"
    Then the response status should be "200"

  Scenario: GET list with JSON content type
    Given I send and accept JSON
    When I send a GET request to "/"
    Then the response status should be "406"

  Scenario: GET list with JSON content type
    Given I send and accept JSON
    When I send a GET request to "metrics"
    Then the response status should be "200"
    And the response content type should be JSON

  Scenario: GET list with JSON extension
    When I send a GET request to "metrics.json"
    Then the response status should be "200"
    And the response content type should be JSON

  Scenario: GET list with HTML content type
    Given I send and accept HTML
    When I send a GET request to "metrics"
    Then the response status should be "406"

  Scenario: GET list with HTML extension
    When I send a GET request to "metrics.html"
    Then the response status should be "406"

  Scenario: GET list with JSON extension
    When I send a GET request to "metrics.json"
    Then the response content type should be JSON

  Scenario: GET metric with JSON content type
    Given I send and accept JSON
    And there is a metric in the database with the name "membership-coverage"
    When I send a GET request to "metrics/membership-coverage"
    Then the response status should be "200"
    And the response content type should be JSON

  Scenario: GET metric with JSON extension
    Given there is a metric in the database with the name "membership-coverage"
    When I send a GET request to "metrics/membership-coverage.json"
    Then the response status should be "200"
    And the response content type should be JSON

  Scenario: GET metric with HTML content type
    Given I send and accept HTML
    And there is a metric in the database with the name "membership-coverage"
    When I send a GET request to "metrics/membership-coverage"
    Then the response status should be "406"

  Scenario: GET metric with HTML extension
    Given there is a metric in the database with the name "membership-coverage"
    When I send a GET request to "metrics/membership-coverage.html"
    Then the response status should be "406"
