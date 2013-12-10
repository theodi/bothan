Feature: Say Hello, World!

  Scenario: View the home page
    Given I am on "the home page"
    Then I should see "Metrics API"
  
  Scenario: POSTing data
    When I send a POST request to "metrics/membership-coverage" with the following:
      """
      {
        "name": "membership-coverage",
        "time": "2013-12-25 15:00:00",
        "value": {
                  "health": 0.33,
                  "telecoms": 0.33,
                  "energy": 0.33
                 }
      }
      """
    Then the response status should be "201"    
    And the data should be stored in the "membership-coverage" metric
    And the time of the stored metric should be "2013-12-25 15:00:00"
    And the value of the metric should be:
      """
      {"health":0.33,"telecoms":0.33,"energy":0.33}
      """ 
      
  Scenario: GETing data
    Given there is a metric in the database with the name "membership-coverage"
    And it has a time of "2013-12-25 15:00:00"
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
    
