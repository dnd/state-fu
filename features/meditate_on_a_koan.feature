Feature: Meditate on a Koan
  In order to access the Koan from an instance
  As a developer
  I want to be able to get a binding to the Koan which has a context

  Scenario: Object instance of a class with a Koan
    Given there is an empty class OneHandClapping
    And class OneHandClapping includes Zen
    And class OneHandClapping defines a simple Zen::Koan
    And I have an instance of OneHandClapping called @clappy
    When I call @clappy.om()
    Then the result should be a Zen::Meditation
    And its .object should be @clappy
    And its .koan should be OneHandClapping.koan
    And its .koan should be OneHandClapping.koan(:om)


