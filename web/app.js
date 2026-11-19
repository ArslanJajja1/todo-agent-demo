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
      li.classList.toggle('done', todo.done);

      const text = document.createElement('span');
      text.className = 'todo-text';
      text.textContent = todo.text;

      const del = document.createElement('button');
      del.type = 'button';
      del.className = 'delete';
      del.textContent = 'Delete';
      del.setAttribute('aria-label', `Delete "${todo.text}"`);
      del.addEventListener('click', () => {
        try {
          list.remove(todo.id);
          error.textContent = '';
          render();
        } catch (err) {
          error.textContent = err.message;
        }
      });

      li.append(text, del);
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
