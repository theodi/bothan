Feature: Metrics API

  Background:
    Given I send and accept JSON

  Scenario: GET list of all metrics
    Given there is a metric in the database with the name "membership-coverage"
    And there is a metric in the database with the name "membership-count"
    When I send a GET request to "metrics"
    Then the response status should be "200"
    And the JSON response should have "$.metrics[0].name" with the text "membership-count"
    And the JSON response should have "$.metrics[0].url" with the text "http://example.org/metrics/membership-count.json"
    And the JSON response should have "$.metrics[1].name" with the text "membership-coverage"
    And the JSON response should have "$.metrics[1].url" with the text "http://example.org/metrics/membership-coverage.json"

  Scenario: POSTing structured data
    Given I authenticate as the user "foo" with the password "bar"
    When I send a POST request to "metrics/membership-coverage" with the following:
      """
      {
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

  Scenario: POSTing simple data
    Given I authenticate as the user "foo" with the password "bar"
    When I send a POST request to "metrics/membership-count" with the following:
      """
      {
        "time": "2013-12-25T15:00:00+00:00",
        "value": 10
      }
      """
    Then the response status should be "201"
    And the data should be stored in the "membership-count" metric
    And the time of the stored metric should be "2013-12-25T15:00:00+00:00"
    And the value of the metric should be:
      """
      10
      """

  Scenario: GETing structured data
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
    And the JSON response should have "$.time" with the text "2013-12-25T15:00:00.000+00:00"
    And the JSON response should have "$.value.health" with the text "0.34"
    And the JSON response should have "$.value.telecoms" with the text "0.34"
    And the JSON response should have "$.value.energy" with the text "0.34"

  Scenario: GETing simple data
    Given there is a metric in the database with the name "membership-count"
    And it has a time of "2013-12-25T15:00:00+00:00"
    And it has a value of:
      """
      11
      """
    And there is a metric in the database with the name "membership-count"
    And it has a time of "2013-12-24T15:00:00+00:00"
    And it has a value of:
      """
      10
      """
    When I send a GET request to "metrics/membership-count"
    Then the response status should be "200"
    Then the JSON response should have "$.name" with the text "membership-count"
    And the JSON response should have "$.time" with the text "2013-12-25T15:00:00.000+00:00"
    And the JSON response should have "$.value" with the text "11"

  Scenario: GETing data for a single date
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
    And there is a metric in the database with the name "membership-coverage"
    And it has a time of "2013-12-23T15:00:00+00:00"
    And it has a value of:
      """
      {"health":0.32,"telecoms":0.32,"energy":0.32}
      """
    When I send a GET request to "metrics/membership-coverage/2013-12-25T12:00:00+00:00"
    Then the response status should be "200"
    Then the JSON response should have "$.name" with the text "membership-coverage"
    And the JSON response should have "$.time" with the text "2013-12-24T15:00:00.000+00:00"
    And the JSON response should have "$.value.health" with the text "0.33"
    And the JSON response should have "$.value.telecoms" with the text "0.33"
    And the JSON response should have "$.value.energy" with the text "0.33"

  Scenario: GETing data with a referer
    Given there is a metric in the database with the name "membership-coverage"
    And it has a time of "2013-12-25T15:00:00+00:00"
    And it has a value of:
      """
      {"health":0.34,"telecoms":0.34,"energy":0.34}
      """
    And I set headers:
      | Referer | http://theodi.org |
    When I send a GET request to "metrics/membership-coverage.json"
    Then the response status should be "200"

  Scenario: Creating metric defaults
    Given I authenticate as the user "foo" with the password "bar"
    When I send a POST request to "metrics/membership-count/metadata" with the following:
      """
      {
        "type": "pie"
      }
      """
    Then the response status should be "201"
    And the "membership-count" "type" should be "pie"

  Scenario: Updating metric defaults
    Given I authenticate as the user "foo" with the password "bar"
    And the "membership-count" "type" is "pie"
    When I send a POST request to "metrics/membership-count/metadata" with the following:
      """
      {
        "type": "chart"
      }
      """
    Then the response status should be "201"
    And the "membership-count" "type" should be "chart"

  Scenario: Creating metric defaults with an invalid type
    Given I authenticate as the user "foo" with the password "bar"
    When I send a POST request to "metrics/membership-count/metadata" with the following:
      """
      {
        "type": "rubbish-type"
      }
      """
    Then the response status should be "400"
    And the "membership-count" "type" should be ""

  Scenario: Creating metric metadata
    Given I authenticate as the user "foo" with the password "bar"
    When I send a POST request to "metrics/membership-count/metadata" with the following:
      """
      {
        "title": {
          "en": "Member Count"
        },
        "description": {
          "en": "How many members there are"
        }
      }
      """
    Then the response status should be "201"
    And the "membership-count" "title" in locale "en" should be "Member Count"
    And the "membership-count" "description" in locale "en" should be "How many members there are"

  Scenario: Merging metric defaults
    Given I authenticate as the user "foo" with the password "bar"
    And metadata already exists for the metric type "membership-count"
    When I send a POST request to "metrics/membership-count/metadata" with the following:
      """
      {
        "title": {
          "en": "Membership Count"
        }
      }
      """
    Then the response status should be "201"
    And the "membership-count" "title" in locale "en" should be "Membership Count"
    And the "membership-count" "description" in locale "en" should be "How many members there are"

  Scenario: Merging metric defaults with a new locale
    Given I authenticate as the user "foo" with the password "bar"
    And metadata already exists for the metric type "membership-count"
    When I send a POST request to "metrics/membership-count/metadata" with the following:
      """
      {
        "title": {
          "de": "Die Mitgliedschaft Graf"
        }
      }
      """
    Then the response status should be "201"
    And the "membership-count" "title" in locale "en" should be "Member Count"
    And the "membership-count" "title" in locale "de" should be "Die Mitgliedschaft Graf"
    And the "membership-count" "description" in locale "en" should be "How many members there are"

  Scenario: POSTing data in a legacy format
    Given I authenticate as the user "foo" with the password "bar"
    When I send a POST request to "metrics/membership-count" with the following:
      """
      {
        "name": "membership-count",
        "time": "2013-12-25T15:00:00+00:00",
        "value": 10
      }
      """
    Then the response status should be "201"
    And the data should be stored in the "membership-count" metric
    And the time of the stored metric should be "2013-12-25T15:00:00+00:00"
    And the value of the metric should be:
      """
      10
      """
