Feature: Say Hello, World!

  Scenario: View the home page
    Given I am on "the home page"
    Then I should see "Metrics API"
  
  Scenario: POSTing data
    When I send a POST request to "metrics/membership-coverage" with the following:
      """
      {
        "name": "membership-coverage",
        "date": "2013-12-25 15:00:00",
        "value": {
                  "health": 0.33,
                  "telecoms": 0.33,
                  "energy": 0.33
                 }
      }
      """
    Then the response status should be "201"    
    And the JSON should be stored in the database
