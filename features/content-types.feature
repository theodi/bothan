Feature: Content Types
  
  Scenario: GET list 
    Given I send and accept JSON
    When I send a GET request to "metrics"
    Then the response content type should be JSON