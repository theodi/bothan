Feature: Error handling

  Background:
    Given I send and accept JSON  
    
  Scenario: GETing data for a single date
    When I send a GET request to "metrics/membership-coverage/wtf"
    Then the response status should be "400"
    Then the JSON response should have "$.status" with the text "'wtf' is not a valid ISO8601 date/time."
    
  Scenario: GETing a range with invalid from date
    When I send a GET request to "metrics/membership-coverage/wtf/2013-01-01"
    Then the response status should be "400"
    Then the JSON response should have "$.status" with the text "'wtf' is not a valid ISO8601 date/time."
    
  Scenario: GETing a range with invalid to date
    When I send a GET request to "metrics/membership-coverage/2013-01-01/wtf"
    Then the response status should be "400"
    Then the JSON response should have "$.status" with the text "'wtf' is not a valid ISO8601 date/time."
    
  Scenario: GETing a range with two invalid dates
    When I send a GET request to "metrics/membership-coverage/wtf/bbq"
    Then the response status should be "400"
    Then the JSON response should have "$.status" with the text "'wtf' is not a valid ISO8601 date/time. 'bbq' is not a valid ISO8601 date/time."
    
  Scenario: GETing a range with from date after to date
    When I send a GET request to "metrics/membership-coverage/2013-02-02/2013-01-01"
    Then the response status should be "400"
    Then the JSON response should have "$.status" with the text "'from' date must be before 'to' date."
    
  Scenario: GETing a range with invalid from duration
    When I send a GET request to "metrics/membership-coverage/P24H/2013-01-01"
    Then the response status should be "400"
    Then the JSON response should have "$.status" with the text "'P24H' is not a valid ISO8601 duration."
  
  Scenario: GETing a range with invalid from duration
    When I send a GET request to "metrics/membership-coverage/2013-01-01/P24H"
    Then the response status should be "400"
    Then the JSON response should have "$.status" with the text "'P24H' is not a valid ISO8601 duration."
  