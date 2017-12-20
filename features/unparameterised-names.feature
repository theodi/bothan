Feature: Unparameterised metric names

  Background:
    Given I send and accept JSON
    And I set up a Pusher spy

  Scenario: POSTing unparamerized metric names
    Given I authenticate as the user "foo" with the password "bar"
    When I send a POST request to "metrics/My%20Metric" with the following:
      """
      {
        "time": "2013-12-25T15:00:00+00:00",
        "value": 10
      }
      """
    Then the response status should be "201"
    And the Pusher endpoint should have recieved "my-metric" with "updated"
    And the data should be stored in the "my-metric" metric
    And the time of the stored metric should be "2013-12-25T15:00:00+00:00"
    And the value of the metric should be:
      """
      10
      """
    And the "my-metric" "title" in locale "en" should be "My Metric"

  Scenario: Make sure existing titles don't get stamped over
    Given I authenticate as the user "foo" with the password "bar"
    Given there is a metric in the database with the name "my-metric"
    And it has a time of "2013-12-25T15:00:00+00:00"
    And it has a value of:
      """
      10
      """
    And it has a "title" in the locale "en" of "My excellent title"
    When I send a POST request to "metrics/My%20Metric" with the following:
      """
      {
        "time": "2013-12-26T15:00:00+00:00",
        "value": 11
      }
      """
    Then the Pusher endpoint should have recieved "my-metric" with "updated"
    Then the "my-metric" "title" in locale "en" should be "My excellent title"

  Scenario: Fetching unparameterised metric names
    pending
  # TODO - this test seems to indicate a need in the API for :name to be returned as API response
#    Given there is a metric in the database with the name "my-metric"
#    And it has a time of "2013-12-25T15:00:00+00:00"
#    And it has a value of:
#      """
#      10
#      """
#    When I send a GET request to "metrics/My%20Metric"
#    Then the response status should be "200"
#    Then the JSON response should have "$.name" with the text "my-metric"
