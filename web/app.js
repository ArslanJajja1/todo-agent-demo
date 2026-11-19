import { TodoList } from './src/todo.js';

const list = new TodoList();

const form = document.getElementById('add-form');
const input = document.getElementById('todo-input');
const error = document.getElementById('error');
const listEl = document.getElementById('todo-list');
const empty = document.getElementById('empty');

function render() {
  const items = list.items();
  listEl.replaceChildren(
    ...items.map((todo) => {
      const li = document.createElement('li');
      li.textContent = todo.text;
      li.classList.toggle('done', todo.done);
      return li;
    }),
  );
  empty.hidden = items.length > 0;
}

form.addEventListener('submit', (event) => {
  event.preventDefault();
  try {
    list.add(input.value);
    error.textContent = '';
    input.value = '';
    render();
  } catch (err) {
    error.textContent = err.message;
  }
  input.focus();
});

render();
