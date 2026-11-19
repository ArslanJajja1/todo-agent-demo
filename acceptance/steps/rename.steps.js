import assert from 'node:assert/strict';
import { When, Then } from '@cucumber/cucumber';

When('I rename {string} to {string}', function (text, newText) {
  const todo = this.list.items().find((t) => t.text === text);
  try {
    this.list.rename(todo?.id, newText);
  } catch (err) {
    this.error = err;
  }
});

Then('the list contains {string} and {string}', function (first, second) {
  assert.deepEqual(
    this.list.items().map((todo) => todo.text),
    [first, second],
  );
});
