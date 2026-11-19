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

  remove(id) {
    const index = this.#todos.findIndex((todo) => todo.id === id);
    if (index === -1) {
      throw new Error('Todo not found');
    }
    const [removed] = this.#todos.splice(index, 1);
    return { ...removed };
  }

  items() {
    return this.#todos.map((todo) => ({ ...todo }));
  }

  get size() {
    return this.#todos.length;
  }
}
