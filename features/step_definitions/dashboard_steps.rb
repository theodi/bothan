Then /^the dashboard editor has "([^\"]*)" rows and "([^\"]*)" columns$/ do |row_count, column_count|
  within('table#dashboard') do
    expect(page).to have_xpath(".//tr", :count => row_count)
    expect(page).to have_xpath(".//td", :count => column_count)
  end
end

Then /^the dashboard "([^\"]*)" has "([^\"]*)" panels$/ do |slug, number|
  list = find("##{slug}").all('li')
  expect list.size == number
end