Feature: Preserve query-strings

  Background:
    Given I send and accept HTML

  Scenario: Preserve query-string on redirect
    Given the time is "2015-01-01T00:00:00"
    And there is a metric in the database with the name "catface"
    When I send a GET request to "metrics/catface?boxcolour=fa8100"
    Then the response status should be "302"
    And I should get redirected to "http://example.org/metrics/catface/2014-12-02T00:00:00+00:00/2015-01-01T00:00:00+00:00?boxcolour=fa8100"
    And I return to the present in my DeLorean

  Scenario: Preserve only the parts of the query-string that we care about
    Given the time is "2015-01-01T00:00:00"
    And there is a metric in the database with the name "snakeface"
    When I send a GET request to "metrics/snakeface?textcolour=fa8100&foo=bar&boxcolour=000000"
    Then the response status should be "302"
    And I should get redirected to "http://example.org/metrics/snakeface/2014-12-02T00:00:00+00:00/2015-01-01T00:00:00+00:00?boxcolour=000000&textcolour=fa8100"
    And I return to the present in my DeLorean
