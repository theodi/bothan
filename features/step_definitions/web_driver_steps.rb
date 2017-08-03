Given /^I login with user: "([^\"]*)" and pwd: "([^\"]*)" and visit dashboards/ do |username, password |
  page.visit("http://#{username}:#{password}@0.0.0.0:3000/dashboards/new")
end

When /^I select "([^\"]*)" from field "([^\"]*)" in the table "([^\"]*)"/ do |value, field, table|
  within_table(table) do
    select(value, :from => field)
  end
end

Then /^the current URL path is (.+)$/ do |url_path|
  # this could probably be removed by using the path.rb file more intelligently
  current_path = URI.parse(current_url).path
  # byebug
  if current_path.respond_to? :should
    current_path.should == url_path
  else
    assert_equal url_path, current_path
  end
end