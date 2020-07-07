const dbSchema = `
  CREATE TABLE IF NOT EXISTS Note (
    note_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    tag TEXT,
    color TEXT NOT NULL,
    state INTEGER NOT NULL DEFAULT 0,
    created_at INTEGER NOT NULL,
    modified_at INTEGER
    )`;

// 创建房间时用
class NoteRepository {
    constructor(dao) {
        this.dao = dao;
    }

    createTable() {
        return this.dao.run(dbSchema);
    }

    create(user_id, title, content, tag, color, state, created_at, modified_at) {
        return this.dao.run(
            `INSERT INTO Note (user_id, title, content, tag, color, state, created_at, modified_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
            [user_id, title, content, tag, color, state, created_at, modified_at]);
    }

    updateNote(user_id, note_id, title, content, tag, color, state, created_at, modified_at) {
        return this.dao.run(
            `UPDATE Note SET title = ?, content = ?, tag = ?, color = ?, state = ?, created_at = ?, modified_at = ? WHERE user_id = ? and note_id = ?`,
            [title, content, tag, color, state, created_at, modified_at, user_id, note_id]);
    }

    // syncNote(note_id, title, content, tag, color, state, modified_at) {
    //     return this.dao.run(
    //         `UPDATE Note Set title = ?, content = ?, tag = ?, color = ?, state = ?, modified_at = ? WHERE note_id = ?`,
    //         [title, content, tag, color, state, modified_at, note_id]
    //     );
    // }

    syncNote(user_id, created_at, title, content, tag, color, state, modified_at) {
        return this.dao.run(
            `UPDATE Note Set title = ?, content = ?, tag = ?, color = ?, state = ?, modified_at = ? WHERE user_id = ? and created_at = ?`,
            [title, content, tag, color, state, modified_at, user_id, created_at]
        );
    }

    getOneItemByNoteId(note_id) {
        return this.dao.get(
            `SELECT * FROM Note WHERE note_id = ?`, [note_id]);
    }

    getOneItem(user_id, created_at) {
        return this.dao.get(
            `SELECT * FROM Note WHERE user_id = ? and created_at = ?`,
            [user_id, created_at]);
    }

    getAllByUserId(user_id) {
        return this.dao.all(
            `SELECT * FROM Note WHERE user_id = ?`,
            [user_id]);
    }
}


module.exports = NoteRepository;