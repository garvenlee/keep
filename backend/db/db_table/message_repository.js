const dbSchema = `
  CREATE TABLE IF NOT EXISTS Message (
    msg_id INTEGER PRIMARY KEY AUTOINCREMENT,
    message TEXT NOT NULL,
    user_one_id INTEGER DEFAULT 0,
    user_two_id INTEGER DEFAULT 0,
    group_id INTEGER DEFAULT 0,
    timestamp INTEGER NOT NULL,
    FOREIGN KEY(user_one_id) REFERENCES User(user_id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY(user_two_id) REFERENCES User(user_id) ON UPDATE CASCADE ON DELETE CASCADE)
    `;

// 用以保存信息
class MessageRepository {
    constructor(dao) {
        this.dao = dao;
    }

    createTable() {
        return this.dao.run(dbSchema);
    }

    createP2P(message, user_one_id, user_two_id, timestamp) {
        timestamp = timestamp || Math.floor(Date.now() / 1000);
        return this.dao.run(
            `INSERT INTO Message (message, user_one_id, user_two_id, timestamp) VALUES (?, ?, ?, ?)`,
            [message, user_one_id, user_two_id, timestamp]);
    }

    createChatRoom(message, user_one_id, group_id, timestamp) {
        timestamp = timestamp || Math.floor(Date.now() / 1000);
        return this.dao.run(
            `INSERT INTO Message (message, user_one_id, group_id, timestamp) VALUES (?, ?, ?, ?)`,
            [message, user_one_id, group_id, timestamp]);
    }

    getChatList(group_id) {
        return this.dao.run(
            `SELECT * FROM Message WHERE group_id = ?`,
            [group_id]);
    }
}


module.exports = MessageRepository;