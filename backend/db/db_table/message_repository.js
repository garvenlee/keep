const dbSchema = `
  CREATE TABLE IF NOT EXISTS Message (
    msg_id INTEGER PRIMARY KEY AUTOINCREMENT,
    chat_type INTEGER NOT NULL,
    message_type TEXT NOT NULL,
    message_body TEXT NOT NULL,
    creator_id INTEGER NOT NULL,
    recipient_id INTEGER DEFAULT 0,
    recipient_group_id INTEGER DEFAULT 0,
    create_at INTEGER NOT NULL,
    expired_at INTEGER NOT NULL,
    is_delete INTEGER DEFAULT 0,
    is_sended INTEGER DEFAULT 1
    );`;

// chat_type: 1 is p2p, 2 is group

// message_type: img/audio/text
// message_body: "hello, world"

// expired_at 用于记录消息的过期时间
// => 可用于消息漫游
// => 设定30天漫游

// 用以保存信息
class MessageRepository {
    constructor(dao) {
        this.dao = dao;
    }

    createTable() {
        return this.dao.run(dbSchema);
    }

    createP2P(message_type, message_body, creator_id, recipient_id, create_at, expired_at, is_sended = 1, chat_type = 1) {
        return this.dao.run(
            `INSERT INTO Message (chat_type, message_type, message_body, creator_id, recipient_id, create_at, expired_at, is_sended) VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
            [chat_type, message_type, message_body, creator_id, recipient_id, create_at, expired_at, is_sended]);
    }

    createGroup(message_type, message_body, creator_id, recipient_group_id, create_at, expired_at, chat_type = 2) {
        return this.dao.run(
            `INSERT INTO Message (chat_type, message_type, message_body, creator_id, recipient_group_id, create_at, expired_at) VALUES (?, ?, ?, ?, ?, ?, ?)`,
            [chat_type, message_type, message_body, creator_id, recipient_group_id, create_at, expired_at]);
    }

    updateOverIsSended(msg_id) {
        return this.dao.run(
            `UPDATE Message SET is_sended = 1 WHERE msg_id = ?`,
            [msg_id]
        );
    }

    getOneP2PByMsgId(msg_id) {
        return this.dao.get(
            `SELECT * FROM Message WHERE msg_id = ?`,
            [msg_id]);
    }

    getOneP2PByReId(recipient_id) {
        return this.dao.get(
            `SELECT * FROM Message WHERE recipient_id = ?`,
            [recipient_id]);
    }

    getAllByUserId(user_id) {
        return this.dao.all(
            `SELECT * FROM Message WHERE (creator_id = ? or recipient_id = ?) and is_sended = 1`,
            [user_id, user_id]
        );
    }
}

module.exports = MessageRepository;