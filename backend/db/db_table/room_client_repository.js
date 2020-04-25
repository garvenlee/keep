const dbSchema = `
  CREATE TABLE IF NOT EXISTS RoomClient (
    client_id INTEGER PRIMARY KEY AUTOINCREMENT,
    room_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    timestamp INTEGER NOT NULL,
    FOREIGN KEY (room_id) REFERENCES Room(room_id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES User(user_id) ON UPDATE CASCADE ON DELETE CASCADE
    )`;


// 用来维系房间内的成员信息
class RoomClientRepository {
    constructor(dao) {
        this.dao = dao;
    }

    createTable() {
        return this.dao.run(dbSchema);
    }

    create(room_id, user_id, timestamp) {
        timestamp = timestamp || Math.floor(Date.now() / 1000);
        return this.dao.run(`INSERT INTO Room (room_id, user_id, timestamp) VALUES (?, ?, ?)`,
            [room_id, user_id, timestamp]);
    }

    delete(room_id, user_id) {
        return this.dao.run(
            `DELETE FROM RoomClient WHERE room_id = ? and user_id = ?`,
            [room_id, user_id]);
    }

    getAllByUserId(user_id) {
        return this.dao.all(
            `SELECT * FROM RoomClient WHERE user_id = ?`,
            [user_id]);
    }

    getChatList(room_id) {
        return this.dao.run(
            `SELECT * FROM Room WHERE room_id = ?`,
            [room_id]);
    }
}


module.exports = RoomClientRepository;