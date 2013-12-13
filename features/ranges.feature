Feature: Time ranges

  Background:
    Given I send and accept JSON
    And there is a metric in the database with the name "membership-coverage"
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
    And there is a metric in the database with the name "membership-coverage"
    And it has a time of "2013-12-23T15:00:00+00:00"
    And it has a value of:
      """
      {"health":0.32,"telecoms":0.32,"energy":0.32}
      """
    And there is a metric in the database with the name "membership-coverage"
    And it has a time of "2013-12-22T15:00:00+00:00"
    And it has a value of:
      """
      {"health":0.31,"telecoms":0.31,"energy":0.31}
      """
  
  Scenario: From specific time to specific time
    When I send a GET request to "metrics/membership-coverage/2013-12-23T12:00:00+00:00/2013-12-25T12:00:00+00:00"
    Then the response status should be "200"
    And the JSON response should have "$.count" with the text "2"
    And the JSON response should have "$.values[0].value.health" with the text "0.32"
    And the JSON response should have "$.values[0].time" with the text "2013-12-23T15:00:00+00:00"
    And the JSON response should have "$.values[1].value.health" with the text "0.33"
    And the JSON response should have "$.values[1].time" with the text "2013-12-24T15:00:00+00:00"

  Scenario: From * to specific time
    When I send a GET request to "metrics/membership-coverage/*/2013-12-25T12:00:00+00:00"
    Then the response status should be "200"
    And the JSON response should have "$.count" with the text "3"
    And the JSON response should have "$.values[0].value.health" with the text "0.31"
    And the JSON response should have "$.values[0].time" with the text "2013-12-22T15:00:00+00:00"
    And the JSON response should have "$.values[1].value.health" with the text "0.32"
    And the JSON response should have "$.values[1].time" with the text "2013-12-23T15:00:00+00:00"
    And the JSON response should have "$.values[2].value.health" with the text "0.33"
    And the JSON response should have "$.values[2].time" with the text "2013-12-24T15:00:00+00:00"

  Scenario: From specific time to *
    When I send a GET request to "metrics/membership-coverage/2013-12-23T12:00:00+00:00/*"
    Then the response status should be "200"
    And the JSON response should have "$.count" with the text "3"
    And the JSON response should have "$.values[0].value.health" with the text "0.32"
    And the JSON response should have "$.values[0].time" with the text "2013-12-23T15:00:00+00:00"
    And the JSON response should have "$.values[1].value.health" with the text "0.33"
    And the JSON response should have "$.values[1].time" with the text "2013-12-24T15:00:00+00:00"
    And the JSON response should have "$.values[2].value.health" with the text "0.34"
    And the JSON response should have "$.values[2].time" with the text "2013-12-25T15:00:00+00:00"
    
  Scenario: From * to *
    When I send a GET request to "metrics/membership-coverage/*/*"
    Then the response status should be "200"
    And the JSON response should have "$.count" with the text "4"
    And the JSON response should have "$.values[0].value.health" with the text "0.31"
    And the JSON response should have "$.values[0].time" with the text "2013-12-22T15:00:00+00:00"
    And the JSON response should have "$.values[1].value.health" with the text "0.32"
    And the JSON response should have "$.values[1].time" with the text "2013-12-23T15:00:00+00:00"
    And the JSON response should have "$.values[2].value.health" with the text "0.33"
    And the JSON response should have "$.values[2].time" with the text "2013-12-24T15:00:00+00:00"
    And the JSON response should have "$.values[3].value.health" with the text "0.34"
    And the JSON response should have "$.values[3].time" with the text "2013-12-25T15:00:00+00:00"
  
  Scenario: From duration up to specific time
    When I send a GET request to "metrics/membership-coverage/P2D/2013-12-25T12:00:00+00:00"
    Then the response status should be "200"
    And the JSON response should have "$.count" with the text "2"
    And the JSON response should have "$.values[0].value.health" with the text "0.32"
    And the JSON response should have "$.values[0].time" with the text "2013-12-23T15:00:00+00:00"
    And the JSON response should have "$.values[1].value.health" with the text "0.33"
    And the JSON response should have "$.values[1].time" with the text "2013-12-24T15:00:00+00:00"
    
  Scenario: From specific time for duration
    When I send a GET request to "metrics/membership-coverage/2013-12-22T12:00:00+00:00/PT24H"
    Then the response status should be "200"
    And the JSON response should have "$.count" with the text "1"
    And the JSON response should have "$.values[0].value.health" with the text "0.31"
    And the JSON response should have "$.values[0].time" with the text "2013-12-22T15:00:00+00:00"
  