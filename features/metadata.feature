Feature: Metrics API

  Background:
    Given I send and accept JSON

  Scenario: Creating metric defaults
    Given I authenticate as the user "foo" with the password "bar"
    When I send a POST request to "metrics/membership-count/metadata" with the following:
      """
      {
        "type": "pie",
        "datatype": "percentage"
      }
      """
    Then the response status should be "201"
    And the "membership-count" "type" should be "pie"
    And the "membership-count" "datatype" should be "percentage"

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

  Scenario: Do not create metric defaults when passed an invalid type
    Given I authenticate as the user "foo" with the password "bar"
    And there is a metric in the database with the name "membership-count"
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

  Scenario: edit metadata for metric endpoint
    Given I authenticate as the user "foo" with the password "bar"
    Given I am logged in as "foo" with "bar"
    And there is a metric in the database with the name "membership-count"
    And metadata already exists for the metric type "membership-count"
    And I go to "metrics/membership-count/metadata"
    Then the page should contain an element "form"
    And the form should contain a field "title[en]"
    And the form should contain a field "description[en]"
    And the form should contain a field "type"
    And the form should contain a field "datatype"
    And the form field "title[en]" should contain a value "Member Count"
    And the form field "description[en]" should contain a value "How many members there are"
