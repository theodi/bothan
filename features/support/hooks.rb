Before do
#  DatabaseCleaner.start
  DatabaseCleaner.clean
end

After do
  DatabaseCleaner.clean
end

Before ('@javascript') do
  Metric.create(name: "dashboard-0")
  # TODO - is there a better way to accomplish this
end