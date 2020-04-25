const dbSchema = `
  CREATE TABLE IF NOT EXISTS MessageClient (
    client_id INTEGER PRIMARY KEY AUTOINCREMENT,
    msg_id INTEGER NOT NULL,
    recipient_id INTEGER DEFAULT 0,
    recipient_group_id INTEGER DEFAULT 0,
    FOREIGN KEY (msg_id) REFERENCES Message(msg_id) ON DELETE CASCADE ON UPDATE CASCADE
    );`;


// chat_type: 1 is p2p, 2 is group
// is_read 表示用户是否收到消息
// => 可利用这个来实现离线消息
// => 1表示接受到， 0表示未接收到
// 用以保存信息
class MessageClientRepository {
    constructor(dao) {
        this.dao = dao;
    }

    createTable() {
        return this.dao.run(dbSchema);
    }

    createP2P(msg_id, recipient_id) {
        return this.dao.run(
            `INSERT INTO MessageClient (msg_id, recipient_id) VALUES (?, ?)`,
            [msg_id, recipient_id]);
    }

    createGroup(msg_id, recipient_group_id) {
        return this.dao.run(
            `INSERT INTO MessageClient (msg_id, recipient_group_id) VALUES (?, ?)`,
            [msg_id, recipient_group_id]);
    }

    getAllP2PByUserId(recipient_id) {
        return this.dao.all(
            `SELECT * FROM MessageClient WHERE recipient_id = ?`,
            [recipient_id]);
    }

    delete(recipient_id) {
        return this.dao.all(
            `DELETE FROM MessageClient WHERE recipient_id = ?`,
            [recipient_id]);
    }
}


module.exports = MessageClientRepository;