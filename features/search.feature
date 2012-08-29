@search

Feature: Search
  In order to find a gem I want
  As a ruby developer
  I should be able to search for gems on gemcutter

  Scenario Outline: Search
    Given the following versions exist:
      | rubygem          | description  |
      | name: LDAP       | mail stuff   |
      | name: twitter    | social junk  |
      | name: beer_laser | amazing beer |
    When I go to the homepage
    And I fill in "query" with "<query>"
    And I press "Search"
    Then I should see "<result>"

    Examples:
      | query      | result       |
      | twitter    | social junk  |
      | beer       | beer_laser   |
      | ldap       | mail stuff   |
      | beer laser | amazing beer |
      | LDAP       | Exact match  |

  Scenario: Exact match not found
    Given the following version exists:
      | rubygem              | description |
      | name: foos-paperclip | paperclip   |
    When I go to the homepage
    And I fill in "query" with "paperclip"
    And I press "Search"
    Then I should not see "Exact match"
    But I should see "foos-paperclip"

  Scenario: The only pushed version of a gem is yanked
    Given the following version exists:
      | rubygem    | number | indexed |
      | name: RGem | 1.0.0  | false   |
    When I go to the homepage
    And I fill in "query" with "RGem"
    And I press "Search"
    Then I should not see "RGem (1.0.0)"

  Scenario: The most recent version of a gem is yanked
    Given the following versions exist:
      | rubygem    | number | indexed |
      | name: RGem | 1.2.1  | true    |
      | name: RGem | 1.2.2  | false   |
    When I go to the homepage
    And I fill in "query" with "RGem"
    And I press "Search"
    And I should see "RGem (1.2.1)"
    And I should not see "RGem (1.2.2)"

  Scenario: The most downloaded gem is listed first
    Given a rubygem "Cereal-Bowl" exists with version "0.0.1" and 500 downloads
    And a rubygem "Cereal" exists with version "0.0.9" and 5 downloads
    When I go to the homepage
    And I fill in "query" with "cereal"
    And I press "Search"
    Then I should see these search results:
      | Cereal-Bowl (0.0.1) |
      | Cereal (0.0.9)      |

  Scenario: The most downloaded gem is listed first and the rest of results is ordered alphabetically
    Given a rubygem "Straight-F" exists with version "0.0.1" and 10 downloads
    And a rubygem "Straight-B" exists with version "0.0.1" and 0 downloads
    And a rubygem "Straight-A" exists with version "0.0.1" and 0 downloads
    When I go to the homepage
    And I fill in "query" with "straight"
    And I press "Search"
    Then I should see these search results:
      | Straight-F (0.0.1) |
      | Straight-A (0.0.1) |
      | Straight-B (0.0.1) |

  Scenario: The user enters a search query with incorrect syntax
    When I go to the homepage
    And I fill in "query" with "bang!"
    And I press "Search"
    Then I should not see /Displaying.*Rubygem/
    But I should see "Sorry, your query is incorrect."
