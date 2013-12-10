Then(/^the JSON should be stored in the database$/) do
  metric = Metric.last 
  metric.name.should == "membership-coverage"
end