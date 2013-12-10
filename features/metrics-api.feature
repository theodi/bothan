Feature: Metrics API

  Background:
    Given I send and accept JSON
  
  Scenario: GET list of all metrics
    Given there is a metric in the database with the name "membership-coverage"
    And there is a metric in the database with the name "membership-count"
    When I send a GET request to "metrics"
    Then the response status should be "200"
    And the JSON response should have "$.metrics[0].name" with the text "membership-coverage"
    And the JSON response should have "$.metrics[0].url" with the text "http://example.org/metrics/membership-coverage.json"
    And the JSON response should have "$.metrics[1].name" with the text "membership-count"
    And the JSON response should have "$.metrics[1].url" with the text "http://example.org/metrics/membership-count.json"
    
  Scenario: POSTing data
    When I send a POST request to "metrics/membership-coverage" with the following:
      """
      {
        "name": "membership-coverage",
        "time": "2013-12-25T15:00:00+00:00",
        "value": {
                  "health": 0.33,
                  "telecoms": 0.33,
                  "energy": 0.33
                 }
      }
      """
    Then the response status should be "201"    
    And the data should be stored in the "membership-coverage" metric
    And the time of the stored metric should be "2013-12-25T15:00:00+00:00"
    And the value of the metric should be:
      """
      {"health":0.33,"telecoms":0.33,"energy":0.33}
      """ 
      
  Scenario: GETing data
    Given there is a metric in the database with the name "membership-coverage"
    And it has a time of "2013-12-25T15:00:00+00:00"
    And it has a value of:
      """
      {"health":0.34,"telecoms":0.34,"energy":0.34}
      """
    And there is a metric in the database with the name "membership-coverage"
    And it has a time of "2013-12-24T15:00:00+00:00"
    And it has a value of:
      """
      {"health":0.33,"telecoms":0.33,"energy":0.33}
      """
    When I send a GET request to "metrics/membership-coverage"
    Then the response status should be "200"
    Then the JSON response should have "$.name" with the text "membership-coverage"
    And the JSON response should have "$.time" with the text "2013-12-25T15:00:00+00:00"
    And the JSON response should have "$.value.health" with the text "0.33"
    And the JSON response should have "$.value.telecoms" with the text "0.33"
    And the JSON response should have "$.value.energy" with the text "0.33"
    
