Before do
#  DatabaseCleaner.start
  DatabaseCleaner.clean
end

After do
  DatabaseCleaner.clean
end

Before ('@dashboard') do
  Metric.create(name: "dashboard-0")
end

Before ('@deletion') do
  Metric.create(name: "delete-me",time: "2017-08-03T15:00:00+00:00")
end