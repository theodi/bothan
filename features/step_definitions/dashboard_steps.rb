Then /^the dashboard "([^\"]*)" has "([^\"]*)" panels$/ do |slug, number|
  # byebug
  list = find("##{slug}").all('li')
  expect list.size == number
end