before do
  DatabaseCleaner.start
end

after do
  DatabaseCleaner.clean
end