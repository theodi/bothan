Feature: Metrics API

  Background:
    Given I send and accept JSON
    And I set up a Pusher spy

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
    And the Pusher endpoint should have recieved "membership-coverage" with "updated"
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
    And the Pusher endpoint should have recieved "membership-count" with "updated"
    And the data should be stored in the "membership-count" metric
    And the time of the stored metric should be "2013-12-25T15:00:00+00:00"
    And the value of the metric should be:
      """
      10
      """

  Scenario: POSTing geodata
    Given I authenticate as the user "foo" with the password "bar"
    When I send a POST request to "metrics/geopoints" with the following:
      """
      {
        "time": "2013-12-25T15:00:00+00:00",
        "value": {
          "type": "FeatureCollection",
          "features": [
            {
              "type": "Feature",
              "geometry": {
                "type": "Point",
                "coordinates": [
                  112,
                  0.7
                ]
              },
              "properties": {
                "prop0": "value0"
              }
            },
            {
              "type": "Feature",
              "geometry": {
                "type": "Point",
                "coordinates": [
                  102,
                  0.5
                ]
              },
              "properties": {
                "prop0": "value0"
              }
            },
            {
              "type": "Feature",
              "geometry": {
                "type": "Point",
                "coordinates": [
                  112,
                  0.8
                ]
              },
              "properties": {
                "prop0": "value0"
              }
            }
          ]
        }
      }
      """
    Then the response status should be "201"
    And the Pusher endpoint should have recieved "geopoints" with "updated"
    And the data should be stored in the "geopoints" metric
    And the time of the stored metric should be "2013-12-25T15:00:00+00:00"
    And the value of the metric should be:
      """
      {"type":"FeatureCollection","features":[{"type":"Feature","geometry":{"type":"Point","coordinates":[112,0.7]},"properties":{"prop0":"value0"}},{"type":"Feature","geometry":{"type":"Point","coordinates":[102,0.5]},"properties":{"prop0":"value0"}},{"type":"Feature","geometry":{"type":"Point","coordinates":[112,0.8]},"properties":{"prop0":"value0"}}]}
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
    And the Pusher endpoint should have recieved "membership-count" with "updated"
    And the data should be stored in the "membership-count" metric
    And the time of the stored metric should be "2013-12-25T15:00:00+00:00"
    And the value of the metric should be:
      """
      10
      """

  Scenario: DELETing simple data
    Given there is a metric in the database with the name "delete-me"
    When I send a GET request to "metrics"
    Then the response status should be "200"
    And the JSON response should have "$.metrics[0].name" with the text "delete-me"
    Given I authenticate as the user "foo" with the password "bar"
    Then I send a DELETE request to "metrics/delete-me"
    And I send a GET request to "metrics"
    Then the response status should be "200"
    And the JSON response should not have "$.metrics[0].name" with the text "delete-me"