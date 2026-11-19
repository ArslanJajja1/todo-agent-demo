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

test('remove deletes the right todo and keeps the order of the rest', () => {
  const list = new TodoList();
  list.add('first');
  const second = list.add('second');
  list.add('third');
  list.remove(second.id);
  assert.deepEqual(list.items().map((t) => t.text), ['first', 'third']);
});

test('remove returns the deleted todo', () => {
  const list = new TodoList();
  const todo = list.add('Buy milk');
  assert.deepEqual(list.remove(todo.id), todo);
});

test('remove with an unknown id throws and leaves the list unchanged', () => {
  const list = new TodoList();
  list.add('Buy milk');
  const before = list.items();
  assert.throws(() => list.remove(999), { message: 'Todo not found' });
  assert.deepEqual(list.items(), before);
});

test('remove on an empty list throws', () => {
  const list = new TodoList();
  assert.throws(() => list.remove(1), { message: 'Todo not found' });
});

test('remove by id leaves another todo with the same text', () => {
  const list = new TodoList();
  const a = list.add('Buy milk');
  const b = list.add('Buy milk');
  list.remove(a.id);
  assert.deepEqual(list.items(), [b]);
});

test('removing the same id twice throws on the second call', () => {
  const list = new TodoList();
  const todo = list.add('Buy milk');
  list.remove(todo.id);
  assert.throws(() => list.remove(todo.id), { message: 'Todo not found' });
});

test('size goes down after a remove', () => {
  const list = new TodoList();
  const todo = list.add('a');
  list.add('b');
  list.remove(todo.id);
  assert.equal(list.size, 1);
});

test('rename changes the text and returns the updated todo', () => {
  const list = new TodoList();
  const todo = list.add('Buy milk');
  const renamed = list.rename(todo.id, 'Buy bread');
  assert.deepEqual(renamed, { ...todo, text: 'Buy bread' });
  assert.equal(list.items()[0].text, 'Buy bread');
});

test('rename keeps the id, done value and order', () => {
  const list = new TodoList();
  list.add('first');
  const second = list.add('second');
  list.add('third');
  list.rename(second.id, 'middle');
  assert.deepEqual(list.items().map((t) => t.text), ['first', 'middle', 'third']);
  assert.deepEqual(list.items()[1], { id: second.id, text: 'middle', done: false });
});

test('rename trims surrounding whitespace', () => {
  const list = new TodoList();
  const todo = list.add('Buy milk');
  assert.equal(list.rename(todo.id, '  Buy bread  ').text, 'Buy bread');
});

for (const bad of ['', '   ', undefined, null]) {
  test(`rename rejects ${JSON.stringify(bad)} and leaves the list unchanged`, () => {
    const list = new TodoList();
    const todo = list.add('Buy milk');
    const before = list.items();
    assert.throws(() => list.rename(todo.id, bad), { message: 'Todo text cannot be empty' });
    assert.deepEqual(list.items(), before);
  });
}

test('rename with an unknown id throws and leaves the list unchanged', () => {
  const list = new TodoList();
  list.add('Buy milk');
  const before = list.items();
  assert.throws(() => list.rename(999, 'x'), { message: 'Todo not found' });
  assert.deepEqual(list.items(), before);
});

test('rename by id leaves another todo with the same text', () => {
  const list = new TodoList();
  const a = list.add('Buy milk');
  const b = list.add('Buy milk');
  list.rename(a.id, 'Buy bread');
  assert.deepEqual(list.items(), [{ ...a, text: 'Buy bread' }, b]);
});

test('size does not change after a rename', () => {
  const list = new TodoList();
  const todo = list.add('a');
  list.add('b');
  list.rename(todo.id, 'c');
  assert.equal(list.size, 2);
});

test('countLabel on an empty list is "0 todos"', () => {
  assert.equal(new TodoList().countLabel(), '0 todos');
});

test('countLabel with one todo is "1 todo"', () => {
  const list = new TodoList();
  list.add('Buy milk');
  assert.equal(list.countLabel(), '1 todo');
});

test('countLabel with two todos is "2 todos"', () => {
  const list = new TodoList();
  list.add('Buy milk');
  list.add('Call mom');
  assert.equal(list.countLabel(), '2 todos');
});

test('countLabel updates after add and remove', () => {
  const list = new TodoList();
  const todo = list.add('a');
  assert.equal(list.countLabel(), '1 todo');
  list.add('b');
  assert.equal(list.countLabel(), '2 todos');
  list.remove(todo.id);
  assert.equal(list.countLabel(), '1 todo');
});

test('countLabel does not change after a failed add', () => {
  const list = new TodoList();
  list.add('Buy milk');
  assert.throws(() => list.add(''));
  assert.equal(list.countLabel(), '1 todo');
});
