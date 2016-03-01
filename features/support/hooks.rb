Before do
#  DatabaseCleaner.start
  DatabaseCleaner.clean
end

After do
  DatabaseCleaner.clean
end
