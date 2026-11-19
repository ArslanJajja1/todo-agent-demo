Feature: Basic todo list

  Scenario: Add a todo
    Given an empty todo list
    When I add "Buy milk"
    Then the list contains only "Buy milk"
    And "Buy milk" is not done

  Scenario: Empty text is rejected
    Given an empty todo list
    When I add ""
    Then I see the error "Todo text cannot be empty"
    And the list has 0 todos
