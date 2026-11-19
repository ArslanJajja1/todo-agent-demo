Feature: Count todos
  Scenario: Show how many todos there are
    Given a todo list with "Buy milk" and "Call mom"
    Then I see "2 todos"
