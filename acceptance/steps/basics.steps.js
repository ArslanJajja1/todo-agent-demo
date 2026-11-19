import assert from 'node:assert/strict';
import { Given, When, Then } from '@cucumber/cucumber';
import { TodoList } from '../../src/todo.js';

Given('an empty todo list', function () {
  this.list = new TodoList();
  this.error = null;
});

When('I add {string}', function (text) {
  try {
    this.list.add(text);
  } catch (err) {
    this.error = err;
  }
});

Then('the list contains only {string}', function (text) {
  assert.deepEqual(
    this.list.items().map((todo) => todo.text),
    [text],
  );
});

Then('{string} is not done', function (text) {
  const todo = this.list.items().find((t) => t.text === text);
  assert.ok(todo, `No todo with text "${text}"`);
  assert.equal(todo.done, false);
});

Then('I see the error {string}', function (message) {
  assert.ok(this.error, 'Expected an error but none was thrown');
  assert.equal(this.error.message, message);
});

Then('the list has {int} todos', function (count) {
  assert.equal(this.list.size, count);
});
