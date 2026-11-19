import assert from 'node:assert/strict';
import { When, Then } from '@cucumber/cucumber';

function mark(world, text, method) {
  const todo = world.list.items().find((t) => t.text === text);
  try {
    world.list[method](todo?.id);
  } catch (err) {
    world.error = err;
  }
}

When('I mark {string} as done', function (text) {
  mark(this, text, 'complete');
});

When('I mark {string} as not done', function (text) {
  mark(this, text, 'uncomplete');
});

Then('{string} is done', function (text) {
  const todo = this.list.items().find((t) => t.text === text);
  assert.ok(todo, `No todo with text "${text}"`);
  assert.equal(todo.done, true);
});
