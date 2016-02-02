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

#  Scenario: GETing simple data
#    Given there is a metric in the database with the name "membership-count"
#    And it has a time of "2013-12-25T15:00:00+00:00"
#    And it has a value of:
#      """
#      11
#      """
#    And there is a metric in the database with the name "membership-count"
#    And it has a time of "2013-12-24T15:00:00+00:00"
#    And it has a value of:
#      """
#      10
#      """
#    When I send a GET request to "metrics/membership-count"
#    Then the response status should be "200"
#    Then the JSON response should have "$.name" with the text "membership-count"
#    And the JSON response should have "$.time" with the text "2013-12-25T15:00:00.000+00:00"
#    And the JSON response should have "$.value" with the text "11"
