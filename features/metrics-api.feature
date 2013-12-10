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
    
