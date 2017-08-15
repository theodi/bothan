Before do
#  DatabaseCleaner.start
  DatabaseCleaner.clean
end

After do
  DatabaseCleaner.clean
end

Before ('@javascript') do
  Metric.create(name: "dashboard-0", time: "2017-08-03T15:00:00+00:00")
  # TODO - is there a better way to accomplish this
end