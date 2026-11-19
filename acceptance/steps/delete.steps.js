import { Given, When } from '@cucumber/cucumber';
import { TodoList } from '../../src/todo.js';

Given('a todo list with {string} and {string}', function (first, second) {
  this.list = new TodoList();
  this.list.add(first);
  this.list.add(second);
  this.error = null;
});

When('I delete {string}', function (text) {
  const todo = this.list.items().find((t) => t.text === text);
  try {
    this.list.remove(todo?.id);
  } catch (err) {
    this.error = err;
  }
});
