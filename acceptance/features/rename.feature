Feature: Rename a todo

  Scenario: Rename a todo
    Given a todo list with "Buy milk" and "Call mom"
    When I rename "Buy milk" to "Buy bread"
    Then the list contains "Buy bread" and "Call mom"

  Scenario: A todo cannot be renamed to empty text
    Given a todo list with "Buy milk" and "Call mom"
    When I rename "Buy milk" to ""
    Then I see the error "Todo text cannot be empty"
