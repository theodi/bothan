Then(/^the data should be stored in the "(.*?)" default$/) do |metric_name|
  @default = MetricDefault.where(name: metric_name).last
  @default.name.should == metric_name
end

Then(/^the type of the stored default should be "(.*?)"$/) do |type|
  @default.type.should == type
end

Given(/^a default already exists for the metric type "(.*?)"$/) do |metric_name|
  @default = MetricDefault.create(name: metric_name, type: 'chart')
end

Given(/^that default has the type "(.*?)"$/) do |type|
  @default.type = type
  @default.save
end

Then(/^there should be (\d+) defaults? with the type "(.*?)"$/) do |num, metric_name|
  MetricDefault.where(name: metric_name).count.should == num.to_i
end
