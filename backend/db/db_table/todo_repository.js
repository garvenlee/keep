const dbSchema = `CREATE TABLE IF NOT EXISTS Todo(
    todo_id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
user_id TEXT NOT NULL,
hasupload TEXT,
description TEXT,
tags TEXT,
ddl TEXT,
is_done Text,
created_at INTEGER,
modified_at INTEGER
);`;

class TodoRepository {
    constructor(dao) {
        this.dao = dao;
    }

    createTable() {
        return this.dao.run(dbSchema);
    }

    create(user_id, hasupload, description, tags, ddl, is_done, created_at, modified_at) {
        return this.dao.run(
            `INSERT INTO Todo (user_id, hasupload, description, tags, ddl, is_done, created_at,modified_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
            [user_id, hasupload, description, tags, ddl, is_done, created_at, modified_at]);
    }

    updateTodo(user_id, todo_id, hasupload, description, tags, ddl, is_done, modified_at) {
        return this.dao.run(
            `UPDATE Todo SET hasupload = ?, description = ?, tags = ?, ddl = ?, is_done = ? WHERE user_id = ? and todo_id = ? and modified_at = ?`,
            [hasupload, description, tags, ddl, is_done, user_id, todo_id, modified_at]);
    }

    syncTodo(user_id, created_at, description, tags, ddl, is_done, modified_at) {
        return this.dao.run(
            `UPDATE Todo Set description = ?, tags = ?, ddl = ?, is_done = ?, modified_at = ? WHERE user_id = ? and created_at = ?`,
            [description, tags, ddl, is_done, modified_at, user_id, created_at]
        );
    }

    getOneItemByTodoId(todo_id) {
        return this.dao.get(
            `SELECT * FROM Todo WHERE todo_id = ?`, [todo_id]);
    }

    getOneItem(user_id, created_at) {
        return this.dao.get(
            `SELECT * FROM Todo WHERE user_id = ? and created_at = ?`,
            [user_id, created_at]);
    }

    getAllByUserId(user_id) {
        return this.dao.all(
            `SELECT * FROM Todo WHERE user_id = ?`,
            [user_id]);
    }
}


module.exports = TodoRepository;