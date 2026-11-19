Feature: Mark a todo as done
  The user ticks off finished work and can undo a mistake.

  Scenario: Complete a todo
    Given a todo list with "Buy milk" and "Call mom"
    When I mark "Buy milk" as done
    Then "Buy milk" is done
    And "Call mom" is not done

  Scenario: Undo a completed todo
    Given a todo list with "Buy milk" and "Call mom"
    When I mark "Buy milk" as done
    And I mark "Buy milk" as not done
    Then "Buy milk" is not done

  Scenario: Completing a todo that does not exist
    Given an empty todo list
    When I mark "Ghost task" as done
    Then I see the error "Todo not found"
