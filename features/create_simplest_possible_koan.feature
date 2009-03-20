Feature: Create the simplest possible Koan (an empty one)
  In order to start using Zen Koans
  As a developer
  I want to be able to create and access the simplest possible Koan

  Scenario: class Empty with no koan defined
    Given there is an empty class Nothing
    And class Nothing includes Zen
    When I call Nothing.koan()
    Then the result should be nil

  Scenario: class Empty instance with no koan defined
    Given there is an empty class Empty
    And class Empty includes Zen
    And I have an instance of Empty called @empty
    When I call @empty.om()
    Then the result should be nil

  Scenario: class Empty with a koan defined
    Given there is an empty class Empty
    And class Empty includes Zen
    When I call Empty.koan() {}
    # And I call Empty.koan()
    Then the result should be a Zen::Koan

  Scenario: class Empty instance with an empty koan
    Given there is an empty class Empty
    And class Empty includes Zen
    And I have an instance of Empty called @empty
    And I call Empty.koan() {}
    When I call @empty.om()
    # And I call Empty.koan()
    Then the result should be a Zen::Meditation

  Scenario: class Empty instance with an empty koan
    Given there is an empty class Empty
    And class Empty includes Zen
    And I have an instance of Empty called @empty
    And I call Empty.koan() {}
    When I call @empty.om()
    Then the result should be a Zen::Meditation
    And @empty.om.koan should be a Zen::Koan
