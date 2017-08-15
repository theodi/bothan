Given /^I login with user: "([^\"]*)" and pwd: "([^\"]*)" and visit "([^\"]*)"$/ do |username, password, path |
  page.visit("http://#{username}:#{password}@#{Capybara.current_session.server.host}:#{Capybara.current_session.server.port}/#{path}/new")
end

When /^I select "([^\"]*)" from field "([^\"]*)" in the table "([^\"]*)"$/ do |value, field, table|
  within_table(table) do
    select(value, :from => field)
  end
end

Then /^the current URL path is (.+)$/ do |url_path|
  current_path = URI.parse(current_url).path
  if current_path.respond_to? :should
    current_path.should == url_path
  else
    assert_equal url_path, current_path
  end
end