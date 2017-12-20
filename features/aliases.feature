Feature: Time aliases

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
    And it has a time of "2013-11-24T15:00:00+00:00"
    And it has a value of:
      """
      {"health":0.33,"telecoms":0.33,"energy":0.33}
      """
    And there is a metric in the database with the name "membership-coverage"
    And it has a time of "2013-12-30T15:00:00+00:00"
    And it has a value of:
      """
      {"health":0.33,"telecoms":0.33,"energy":0.33}
      """
    And there is a metric in the database with the name "membership-coverage"
    And it has a time of "2014-01-01T15:00:00+00:00"
    And it has a value of:
      """
      {"health":0.33,"telecoms":0.33,"energy":0.33}
      """

    Scenario: Using `all` alias
      When I send a GET request to "metrics/membership-coverage/all"
      Then the response status should be "200"
      And the JSON response should have "$.count" with the text "5"

    Scenario: Using `this-month` alias
      Given the time is "2013-12-31T00:00:00Z"
      When I send a GET request to "metrics/membership-coverage/since-beginning-of-month"
      Then the response status should be "200"
      And the JSON response should have "$.count" with the text "3"
      And the JSON response should have "$.values[0].value.health" with the text "0.33"
      And the JSON response should have "$.values[0].time" with the text "2013-12-24T15:00:00.000+00:00"
      And the JSON response should have "$.values[1].value.health" with the text "0.34"
      And the JSON response should have "$.values[1].time" with the text "2013-12-25T15:00:00.000+00:00"
      And the JSON response should have "$.values[2].value.health" with the text "0.33"
      And the JSON response should have "$.values[2].time" with the text "2013-12-30T15:00:00.000+00:00"
      And I return to the present in my DeLorean

    Scenario: Using `latest` alias
      When I send a GET request to "metrics/membership-coverage/latest"
      Then the response status should be "200"
      And the JSON response should have "$.name" with the text "membership-coverage"
      And the JSON response should have "$.value.health" with the text "0.33"
      And the JSON response should have "$.time" with the text "2014-01-01T15:00:00.000+00:00"

    Scenario: Using `this-week` alias
      Given the time is "2013-12-26T00:00:00Z"
      When I send a GET request to "metrics/membership-coverage/since-beginning-of-week"
      Then the response status should be "200"
      And the JSON response should have "$.count" with the text "2"
      And the JSON response should have "$.values[0].value.health" with the text "0.33"
      And the JSON response should have "$.values[0].time" with the text "2013-12-24T15:00:00.000+00:00"
      And the JSON response should have "$.values[1].value.health" with the text "0.34"
      And the JSON response should have "$.values[1].time" with the text "2013-12-25T15:00:00.000+00:00"
      And I return to the present in my DeLorean

    Scenario: Using `this-year` alias
      Given the time is "2014-01-01T20:00:00Z"
      When I send a GET request to "metrics/membership-coverage/since-beginning-of-year"
      And the JSON response should have "$.count" with the text "1"
      And the JSON response should have "$.values[0].value.health" with the text "0.33"
      And the JSON response should have "$.values[0].time" with the text "2014-01-01T15:00:00.000+00:00"

    Scenario: Using `since-midnight` alias
      Given the time is "2013-12-25T18:00:00Z"
      When I send a GET request to "metrics/membership-coverage/since-midnight"
      Then the response status should be "200"
      And the JSON response should have "$.count" with the text "1"
      And the JSON response should have "$.values[0].value.health" with the text "0.34"
      And the JSON response should have "$.values[0].time" with the text "2013-12-25T15:00:00.000+00:00"
      And I return to the present in my DeLorean

    Scenario: Using `today` alias
      pending
#      When I send a GET request to "metrics/membership-coverage/today"
#      Then the response status should be "302"
