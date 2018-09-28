Given("there is a Lasius subspecies without a species") do
  subspecies = create_subspecies "Lasius specius subspecius", species: nil
  expect(subspecies.species).to be nil
end

When("I open all database scripts and browse their sources") do
  @browsed_scripts_count = 0

  script_names = DatabaseScript.all.map &:to_param
  script_names.each do |script_name|
    step %(I open the database script "#{script_name}" and browse its source)
  end
end

When("I open the database script {string} and browse its source") do |script_name|
  visit "/database_scripts/#{script_name}"

  step 'I should see "Show source"'
  step 'I follow "current (antcat.org)"'
  step 'I should see "Back to script"'

  @browsed_scripts_count += 1
end

# Confirm that the scenario didn't pass for the wrong reasons.
Then("I should have browsed at least 5 database scripts") do
  expect(@browsed_scripts_count).to be >= 5
end
