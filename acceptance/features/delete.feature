Feature: Delete a todo

  Scenario: Delete one todo
    Given a todo list with "Buy milk" and "Call mom"
    When I delete "Buy milk"
    Then the list contains only "Call mom"

  Scenario: Deleting a todo that does not exist
    Given an empty todo list
    When I delete "Ghost task"
    Then I see the error "Todo not found"
