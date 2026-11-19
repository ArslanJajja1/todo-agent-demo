export class TodoList {
  #todos = [];
  #nextId = 1;

  #key(text) {
    return String(text).trim().replace(/\s+/g, ' ').toLowerCase();
  }

  add(text) {
    const trimmed = String(text ?? '').trim();
    if (trimmed === '') {
      throw new Error('Todo text cannot be empty');
    }
    const key = this.#key(trimmed);
    if (this.#todos.some((t) => this.#key(t.text) === key)) {
      throw new Error('Todo already exists');
    }
    const todo = { id: this.#nextId++, text: trimmed, done: false };
    this.#todos.push(todo);
    return { ...todo };
  }

  remove(id) {
    const index = this.#todos.findIndex((todo) => todo.id === id);
    if (index === -1) {
      throw new Error('Todo not found');
    }
    const [removed] = this.#todos.splice(index, 1);
    return { ...removed };
  }

  rename(id, text) {
    const trimmed = String(text ?? '').trim();
    if (trimmed === '') {
      throw new Error('Todo text cannot be empty');
    }
    const todo = this.#todos.find((t) => t.id === id);
    if (!todo) {
      throw new Error('Todo not found');
    }
    const key = this.#key(trimmed);
    if (this.#todos.some((t) => t.id !== id && this.#key(t.text) === key)) {
      throw new Error('Todo already exists');
    }
    todo.text = trimmed;
    return { ...todo };
  }

  items() {
    return this.#todos.map((todo) => ({ ...todo }));
  }

  get size() {
    return this.#todos.length;
  }

  countLabel() {
    return `${this.size} ${this.size === 1 ? 'todo' : 'todos'}`;
  }
}
