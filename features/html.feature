Feature: Metrics API

  Background:
    Given I send and accept HTML

  Scenario: GET list of all metrics
    Given there is a metric in the database with the name "membership-coverage"
    And there is a metric in the database with the name "membership-count"
    When I send a GET request to "metrics"
    Then the response status should be "200"
    And the XML response should have "//ul[@id='metrics']"
    # And then it all happens client-side and Cucumber is out of its depth

  Scenario: Redirected to default daterange
    Given the time is "2015-01-01T00:00:00"
    And there is a metric in the database with the name "membership-count"
    When I send a GET request to "metrics/membership-count"
    Then the response status should be "302"
    And I should get redirected to "http://example.org/metrics/membership-count/2014-12-02T00:00:00+00:00/2015-01-01T00:00:00+00:00?"
    And I return to the present in my DeLorean
