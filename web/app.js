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

      const rename = document.createElement('button');
      rename.type = 'button';
      rename.className = 'rename';
      rename.textContent = 'Rename';
      rename.setAttribute('aria-label', `Rename "${todo.text}"`);
      rename.addEventListener('click', () => startRename(li, text, todo));

      li.append(text, rename, del);
      return li;
    }),
  );
  empty.hidden = items.length > 0;
}

function startRename(li, textEl, todo) {
  const edit = document.createElement('input');
  edit.type = 'text';
  edit.className = 'rename-input';
  edit.value = todo.text;
  edit.setAttribute('aria-label', `New text for "${todo.text}"`);

  let finished = false;
  const save = () => {
    if (finished) return;
    try {
      list.rename(todo.id, edit.value);
      finished = true;
      error.textContent = '';
      render();
    } catch (err) {
      error.textContent = err.message;
      edit.focus();
    }
  };
  const cancel = () => {
    finished = true;
    error.textContent = '';
    render();
  };

  edit.addEventListener('keydown', (event) => {
    if (event.key === 'Enter') {
      event.preventDefault();
      save();
    } else if (event.key === 'Escape') {
      event.preventDefault();
      cancel();
    }
  });
  edit.addEventListener('blur', save);

  li.replaceChild(edit, textEl);
  edit.focus();
  edit.select();
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
