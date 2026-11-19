export class TodoList {
  #todos = [];
  #nextId = 1;

  add(text) {
    const trimmed = String(text ?? '').trim();
    if (trimmed === '') {
      throw new Error('Todo text cannot be empty');
    }
    const todo = { id: this.#nextId++, text: trimmed, done: false };
    this.#todos.push(todo);
    return { ...todo };
  }

  items() {
    return this.#todos.map((todo) => ({ ...todo }));
  }

  get size() {
    return this.#todos.length;
  }
}
