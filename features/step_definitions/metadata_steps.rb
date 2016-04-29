Then(/^the "([a-z\-]+)" "([a-z\-]+)" should be "(.*?)"$/) do |metric_name, field, value|
  metadata = MetricMetadata.where(name: metric_name).last
  expect(metadata.send(field)).to eql value == "" ? nil : value
end

Then(/^the "([a-z\-]+)" "([a-z\-]+)" in locale "([a-z\-]+)" should be "(.*?)"$/) do |metric_name, field, locale, value|
  metadata = MetricMetadata.where(name: metric_name).last
  expect(metadata.send(field)[locale]).to eql value
end

Given(/^the "(.*?)" "(.*?)" is "(.*?)"$/) do |metric_name, field, value|
  meta = MetricMetadata.find_or_create_by(name: metric_name)
  meta.send("#{field}=", value)
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
