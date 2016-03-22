@feed
Feature: Feed (references)
  Background:
    Given I log in as a catalog editor named "Archibald"

  Scenario: Started reviewing reference
    Given there is a reference for the feed with state "none"

    When I go to the new references page
    And I follow "Start reviewing"
    And I go to the activity feed
    Then I should see "Archibald started reviewing the reference Giovanni, 1809"

  Scenario: Finished reviewing reference
    Given there is a reference for the feed with state "reviewing"

    When I go to the new references page
    And I follow "Finish reviewing"
    And I go to the activity feed
    Then I should see "Archibald finished reviewing the reference Giovanni, 1809"

  Scenario: Restarted reviewing reference
    Given there is a reference for the feed with state "reviewed"
    When I go to the new references page
    And I follow "Restart reviewing"
    And I go to the activity feed
    Then I should see "Archibald restarted reviewing the reference Giovanni, 1809"

  Scenario: Approved all references
    Given I log in as a superadmin named "Archibald"

    When I create a bunch of references for the feed
    And I go to the references page
    And I follow "Latest Changes"
    And I press "Approve all"
    And I go to the activity feed
    Then I should see "Archibald approved all unreviewed references (2 in total)."
