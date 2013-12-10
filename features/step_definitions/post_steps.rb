Then(/^the data should be stored in the "(.*?)" metric$/) do |metric_name|
  @metric = Metric.where(name: metric_name).last
  @metric.name.should == metric_name
end

Then(/^the time of the stored metric should be "(.*?)"$/) do |time|
  @metric.time.should == DateTime.parse(time)
end

Then(/^the value of the metric should be:$/) do |string|
  @metric.value.to_json.should == string
end