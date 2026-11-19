import { test } from 'node:test';
import assert from 'node:assert/strict';
import { TodoList } from '../src/todo.js';

test('a new list is empty', () => {
  const list = new TodoList();
  assert.equal(list.size, 0);
  assert.deepEqual(list.items(), []);
});

test('add returns a todo that is not done', () => {
  const list = new TodoList();
  const todo = list.add('Buy milk');
  assert.equal(todo.text, 'Buy milk');
  assert.equal(todo.done, false);
  assert.equal(list.size, 1);
});

test('add trims surrounding whitespace', () => {
  const list = new TodoList();
  assert.equal(list.add('  Buy milk  ').text, 'Buy milk');
});

for (const bad of ['', '   ', undefined, null]) {
  test(`add rejects ${JSON.stringify(bad)}`, () => {
    const list = new TodoList();
    assert.throws(() => list.add(bad), { message: 'Todo text cannot be empty' });
    assert.equal(list.size, 0);
  });
}

test('ids are unique', () => {
  const list = new TodoList();
  const a = list.add('a');
  const b = list.add('b');
  assert.notEqual(a.id, b.id);
});

test('items keeps insertion order', () => {
  const list = new TodoList();
  list.add('first');
  list.add('second');
  assert.deepEqual(list.items().map((t) => t.text), ['first', 'second']);
});

test('items returns copies that cannot mutate the list', () => {
  const list = new TodoList();
  list.add('Buy milk');
  const items = list.items();
  items[0].done = true;
  items.push({ id: 99, text: 'x', done: false });
  assert.equal(list.items()[0].done, false);
  assert.equal(list.size, 1);
});
