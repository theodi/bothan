Given(/^that metric has a default type of "(.*?)"$/) do |view|
  @hash ||= {}
  @hash[@metric.name] ||= {}
  @hash[@metric.name]['defaults'] ||= {}
  @hash[@metric.name]['defaults']['type'] = view
  allow_any_instance_of(Bothan::App).to receive(:metrics_config) {
    @hash
  }
end

Given(/^that metric has a default datetime of "(.*?)"$/) do |datetime|
  @hash ||= {}
  @hash[@metric.name] ||= {}
  @hash[@metric.name]['defaults'] ||= {}
  @hash[@metric.name]['defaults']['datetime'] = datetime
  allow_any_instance_of(Bothan::App).to receive(:metrics_config) {
    @hash
  }
end
