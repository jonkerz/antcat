@javascript
Feature: Converting a species to a subspecies
  As an editor of AntCat
  I want to make a species a subspecies
  So the data is correct

  Scenario: Converting a species to a subspecies
    Given there is a species "Camponotus dallatorei"
    And there is a species "Camponotus alii"
    And I am logged in
    When I go to the edit page for "Camponotus dallatorei"
    And I press "Convert to subspecies"
    Then I should be on the "Convert to subspecies" page

  Scenario: Converting a species to a subspecies when it already exists

  Scenario: Only show button if showing a species
    Given there is a subspecies "Camponotus dallatorei alii"
    And I am logged in
    When I go to the edit page for "Camponotus dallatorei alii"
    Then I should not see "Convert to subspecies"
