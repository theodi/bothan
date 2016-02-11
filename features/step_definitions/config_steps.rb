Given(/^that metric has a default view of "(.*?)"$/) do |arg1|

end

Given(/^that metric has a default datetime of "(.*?)"$/) do |datetime|
  allow_any_instance_of(MetricsApi).to receive(:metrics_config) {
    {
      "#{@metric.name}" => {
        'default-datetime' => datetime
      }
    }
  }
end
