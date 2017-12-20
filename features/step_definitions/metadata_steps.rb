Then(/^the "([a-z\-]+)" "([a-z\-]+)" should be "(.*?)"$/) do |metric_name, field, value|
  metadata = MetricMetadata.where(name: metric_name).last
  expect(metadata.send(field)).to eql value == "" ? nil : value
end

Then(/^there should be no metadata persisted for "(.*?)"$/) do |metric_name|
  expect(MetricMetadata.where(name: metric_name).exists?).to eql false
end

Then(/^the "([a-z\-]+)" "([a-z\-]+)" in locale "([a-z\-]+)" should be "(.*?)"$/) do |metric_name, field, locale, value|
  metadata = MetricMetadata.where(name: metric_name).last
  expect(metadata.send(field)[locale]).to eql value
end

Given(/^it has a "(.*?)" in the locale "(.*?)" of "(.*?)"$/) do |key, locale, value|
  steps %Q{
    When I send a POST request to "metrics/#{@metric.name}/metadata" with the following:
      """
      {
        "#{key}": {
          "#{locale}": "#{value}"
        }
      }
      """
    Then the response status should be "201"
  }
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

Then(/^I should see a form$/) do
  body = Nokogiri::HTML(last_response.body)
  @form = body.css('form')

  expect(@form).to_not be(nil)
end

Then(/^the form should have a field "(.*?)"$/) do |name|
  expect(@form.css("[name='#{name}']")).to_not be(nil)
end
