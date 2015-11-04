@javascript
Feature: Adding a taxon
  As an editor of AntCat
  I want to add taxa
  So that information is kept up-to-date˜
  So people use AntCat

  Background:
    Given I log in
    And that version tracking is enabled
    And these dated references exist
      | authors | citation   | title | year |  created_at | updated_at | doi |
      | Fisher  | Psyche 3:3 | Ants  | 2004 |   TODAYS_DATE | TODAYS_DATE |  |
    And there is a subfamily "Formicinae"

                          #spurrious failures
  Scenario: Adding a genus
    Given there is a genus "Eciton"
    When I go to the catalog page for "Formicinae"
      And I press "Edit"
      And I press "Add genus"
    Then I should be on the new taxon page
    When I click the name field
      And I set the name to "Atta"
      And I press "OK"
    When I click the protonym name field
      Then the protonym name field should contain "Atta"
    When I set the protonym name to "Eciton"
      And I press "OK"
    When I click the authorship field
      And I search for the author "Fisher"
      And I click the first search result
    And I press "OK"
    When I click the type name field
      Then the type name field should contain "Eciton "
    When I set the type name to "Atta major"
      And I press "OK"
      And I press "Add this name"
    When I save my changes
      Then I should be on the catalog page for "Atta"
      And I should see "Eciton" in the protonym
    When I go to the catalog page for "Formicinae"
      Then I should see "Atta" in the index

    #spurrious failure
  Scenario: Adding a genus which has a tribe
    Given tribe "Ecitonini" exists in that subfamily
    When I go to the catalog page for "Ecitonini"
      And I press "Edit"
      And I press "Add genus"
      And I click the name field
      And I set the name to "Eciton"
      And I press "OK"
    When I click the protonym name field
      And I set the protonym name to "Eciton"
      And I press "OK"
    When I click the authorship field
      And I search for the author "Fisher"
      And I click the first search result
      And I press "OK"
    When I click the type name field
      And I set the type name to "Eciton major"
      And I press "OK"
      And I press "Add this name"
    When I save my changes
      Then I should be on the catalog page for "Eciton"


  Scenario: Adding a genus without setting authorship reference
    Given there is a genus "Eciton"
    When I go to the edit page for "Formicinae"
    And I press "Add genus"
    Then I should be on the new taxon page
    When I click the name field
      And I set the name to "Atta"
      And I press "OK"
    And I click the protonym name field
      And I set the protonym name to "Eciton"
      And I press "OK"
    And I click the type name field
      And I set the type name to "Atta major"
      And I press "OK"
    And I press "Add this name"
    And I save my changes
    Then I should see "Protonym authorship reference can't be blank"


  Scenario: Having an error, but leave fields as user entered them
    When I go to the edit page for "Formicinae"
    And I press "Add genus"
    And I click the name field
      And I set the name to "Atta"
      And I press "OK"
    And I fill in "taxon_type_taxt" with "Notes"
    And I save my changes
    Then I should be on the create taxon page
    And I should see "Protonym name name can't be blank"
    And the "taxon_type_taxt" field should contain "Notes"
    And the name button should contain "Atta"

  Scenario: Cancelling
    And I go to the edit page for "Formicinae"
    And I press "Add genus"
    And I press "Cancel"
    Then I should be on the edit page for "Formicinae"

  Scenario: Adding a species
    Given there is a genus "Eciton"
    When I go to the catalog page for "Eciton"
    And I press "Edit"
    And I press "Add species"
    Then I should be on the new taxon page
    And I should see "new species of "
    And I should see "Eciton"
    When I click the name field
    Then the name field should contain "Eciton "
    When I set the name to "Eciton major"
      And I press "OK"
    And I click the protonym name field
      And I set the protonym name to "Eciton major"
      And I press "OK"
    And I click the authorship field
      And I search for the author "Fisher"
      And I click the first search result
      And I press "OK"
    And I save my changes
    Then I should be on the catalog page for "Eciton major"
    And I should see "Eciton major" in the protonym

  Scenario: Adding a species to a subgenus
    Given subfamily "Dolichoderinae" exists
    And tribe "Dolichoderini" exists in that subfamily
    And genus "Dolichoderus" exists in that tribe
    And species "Dolichoderus major" exists in that genus
    And subgenus "Dolichoderus (Subdolichoderus)" exists in that genus
    When I go to the catalog page for "Dolichoderus (Subdolichoderus)"
    And I press "Edit"
    And I press "Add species"
    Then I should be on the new taxon page
    And I should see "new species of "
    And I should see "Dolichoderus (Subdolichoderus)"
    When I click the name field
    Then the name field should contain "Dolichoderus (Subdolichoderus) "
    When I set the name to "Dolichoderus (Subdolichoderus) major"
    And I press "OK"
    And I click the protonym name field
    And I set the protonym name to "Dolichoderus (Subdolichoderus) major"
    And I press "OK"
    And I click the authorship field
    And I search for the author "Fisher"
    And I click the first search result
    And I press "OK"
    And I save my changes
    Then I should be on the catalog page for "Dolichoderus (Subdolichoderus) major"
    And I should see "Dolichoderus (Subdolichoderus) major" in the protonym


  Scenario: Using a genus's type-species for the name of a species
    When I go to the catalog page for "Formicinae"
    And I press "Edit"
    And I press "Add genus"
    And I click the name field
      And I set the name to "Atta"
      And I press "OK"
    And I click the protonym name field
      And I set the protonym name to "Atta"
      And I press "OK"
    And I click the authorship field
      And I search for the author "Fisher"
      And I click the first search result
      And I press "OK"
    And I click the type name field
      And I set the type name to "Atta major"
      And I press "OK"
      And I press "Add this name"
    And I save my changes
    And the changes are approved
    And I go to the catalog page for "Atta"
    And I press "Edit"
    And I press "Add species"
    When I click the name field
      And I set the name to "Atta major"
      And I press "OK"
    And I click the protonym name field
      And I set the protonym name to "Atta major"
      And I press "OK"
    And I click the authorship field
      And I search for the author "Fisher"
      And I click the first search result
      And I press "OK"
    And I save my changes
    Then I should be on the catalog page for "Atta major"
    And I should see "Atta major" in the protonym


  Scenario: Adding a subspecies
    And there is a species "Eciton major" with genus "Eciton"
    #http://localhost:3000/catalog/6
    When I go to the catalog page for "Eciton major"
    And I press "Edit"
    And I press "Add subspecies"
    Then I should be on the new taxon page
    And I should see "new subspecies of Eciton major"
    When I click the name field
    Then the name field should contain "Eciton major "
    When I set the name to "Eciton major infra"
      And I press "OK"
    And I click the protonym name field
      And I set the protonym name to "Eciton major infra"
      And I press "OK"
    And I click the authorship field
      And I search for the author "Fisher"
      And I click the first search result
      And I press "OK"
    And I save my changes
    Then I should be on the catalog page for "Eciton major infra"
    And I should see "infra" in the index
    And I should see "Eciton major infra" in the protonym

  Scenario: Adding a subfamily
    When I go to the catalog page for "Family"
      And I press "Edit"
      And I press "Add subfamily"
    Then I should be on the new taxon page
    When I click the name field
      And I set the name to "Dorylinae"
      And I press "OK"
    When I click the protonym name field
      Then the protonym name field should contain "Dorylinae"
    When I press "OK"
    And I click the authorship field
      And I search for the author "Fisher"
      And I click the first search result
      And I press "OK"
    When I click the type name field
      Then the type name field should contain "Dorylinae "
    When I set the type name to "Atta"
      And I press "OK" in "#type_name_field"
      And I press "Add this name"
    When I save my changes
      Then I should be on the catalog page for "Dorylinae"
      And I should see "Dorylinae" in the protonym
    When I go to the catalog page for "Formicinae"
      Then I should see "Dorylinae" in the index

  Scenario: Adding a tribe
    When I go to the catalog page for "Formicinae"
      And I press "Edit"
      And I press "Add tribe"
    Then I should be on the new taxon page
    When I click the name field
      And I set the name to "Dorylini"
      And I press "OK"
    When I click the protonym name field
      Then the protonym name field should contain "Dorylini"
    When I press "OK"
    And I click the authorship field
      And I search for the author "Fisher"
      And I click the first search result
      And I press "OK"
    When I save my changes
      Then I should be on the catalog page for "Dorylini"
      And I should see "Dorylini" in the protonym
    When I go to the catalog page for "Formicinae"
      Then I should see "Dorylini" in the tribes index
