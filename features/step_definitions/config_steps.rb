Given(/^that metric has a default type of "(.*?)"$/) do |view|
  @hash ||= {}
  @hash[@metric.name] ||= {}
  @hash[@metric.name]['defaults'] ||= {}
  @hash[@metric.name]['defaults']['type'] = view
  allow_any_instance_of(MetricsApi).to receive(:metrics_config) {
    @hash
  }
end

Given(/^that metric has a default datetime of "(.*?)"$/) do |datetime|
  @hash ||= {}
  @hash[@metric.name] ||= {}
  @hash[@metric.name]['defaults'] ||= {}
  @hash[@metric.name]['defaults']['datetime'] = datetime
  allow_any_instance_of(MetricsApi).to receive(:metrics_config) {
    @hash
  }
end

Given(/^that metric has a value\-path of "(.*?)"$/) do |xpath|
  @hash ||= {}
  @hash[@metric.name] ||= {}
  @hash[@metric.name]['value-path'] = xpath
  allow_any_instance_of(MetricsApi).to receive(:metrics_config) {
    @hash
  }
end
