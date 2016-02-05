Given(/^there is a metric in the database with the name "(.*?)"$/) do |name|
  @metric = Metric.create(name: name, time: DateTime.now)
end

Given(/^it has a time of "(.*?)"$/) do |time|
  @metric.time = time
  @metric.save
end

Given(/^it has a value of:$/) do |value|
  @metric.value = value.include?('{') ? JSON.parse(value) : value.to_i
  @metric.save
end

And(/^I should get redirected to "(.*?)"$/) do |location|
  expect(location).to eq last_response.location
end

Given(/^the time is "(.*?)"$/) do |timestamp|
  Timecop.freeze Time.parse timestamp
end

Then(/^I return to the present in my DeLorean$/) do
  Timecop.return
end
