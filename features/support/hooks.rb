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