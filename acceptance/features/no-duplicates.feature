Feature: No duplicate todos
  A course manager should not see the same task twice.

  Scenario: Adding the same todo twice is rejected
    Given an empty todo list
    When I add "Buy milk"
    And I add "Buy milk"
    Then I see the error "Todo already exists"
    And the list has 1 todos

  Scenario: Duplicates are found even with different spacing or capitals
    Given an empty todo list
    When I add "Buy milk"
    And I add "  buy MILK "
    Then I see the error "Todo already exists"
    And the list has 1 todos
