Then(/^the "(.*?)" "(.*?)" in locale "(.*?)" should be "(.*?)"$/) do |metric_name, field, locale, value|
  metadata = MetricMetadata.where(name: metric_name).last
  expect(metadata.send(field)[locale]).to eql value
end

Given(/^metadata already exists for the metric type "(.*?)"$/) do |metric_name|
  steps %Q{
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
  }
end