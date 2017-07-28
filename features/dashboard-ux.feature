Feature: Dashboard UX

  Background: Given I send and accept HTML
    And there is a metric in the database with the name "membership-coverage"
    And it has a time of "2013-12-25T15:00:00+00:00"
    And it has a value of:
      """
      {"health":0.34,"telecoms":0.34,"energy":0.34}
      """

    Scenario: Create a Dashboard With Name
      Given I authenticate as the user "foo" with the password "bar"
      And I send a GET request to "dashboards/new"
#      And I go to "dashboards/new" #doesn't work - uncertain if anything in web_steps works
      Then I should see a form
      And the form should have a field "dashboard[name]"
      # AND I should see Dashboard Name
      # AND I INPUT @NAME // necessary for redirect
      # THEN I click submit
      # THEN I SHOULD BE ON http://localhost:9292/dashboards/@name / open_page method


    Scenario: Ensure only chosen metrics populate dashboard
      Given I authenticate as the user "foo" with the password "bar"
      And I send a GET request to "dashboards/new"
      Then I should see a form
      # NUTS ^ the above has to be in sequence otherwise this feature fails - that doesnt seem right
      # AND I should see number of rows value 3 <input type="number" class="form-control rowcols" id="rows" value="3" name="dashboard[rows]" min="1" max="3">
      # AND I should see number of cols value 3 <input type="number" class="form-control rowcols" id="columns" value="3" name="dashboard[columns]" min="1" max="4">
      # TODO steps needed to check for existence of Box Colour, Text Colour, Width, Height AKA fields present PRIOR to metric select
      And I choose "membership-coverage" within "metric"
      Then the form should have a field "title"
      # ensure that selected metric exclusive fields have been made visible: Metric Title, Date Range
      # THEN I click submit
      # THEN I SHOULD BE ON http://localhost:9292/dashboards/@name / open_page method