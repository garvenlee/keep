const dbSchema = `
  CREATE TABLE IF NOT EXISTS RoomClient (
    client_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    room_id INTEGER NOT NULL,
    timestamp INTEGER NOT NULL,
    FOREIGN KEY (user_id) REFERENCES User(user_id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (room_id) REFERENCES Room(room_id) ON UPDATE CASCADE ON DELETE CASCADE
    )`;


// 用来维系房间内的成员信息
class RoomClientRepository {
    constructor(dao) {
        this.dao = dao;
    }

    createTable() {
        return this.dao.run(dbSchema);
    }

    addMember(room_name, room_size, timestamp) {
        timestamp = timestamp || Math.floor(Date.now() / 1000);
        return this.dao.run(`INSERT INTO Room (room_name, room_size, timestamp) VALUES (?, ?, ?)`,
            [room_name, room_size, timestamp]);
    }

    getChatList(room_id) {
        return this.dao.run(
            `SELECT * FROM Room WHERE room_id = ?`,
            [room_id]);
    }
}


module.exports = RoomClientRepository;