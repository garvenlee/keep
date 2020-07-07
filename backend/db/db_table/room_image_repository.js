const dbSchema = `CREATE TABLE IF NOT EXISTS RoomImage (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
img_path TEXT NOT NULL,
room_id INTEGER NOT NULL,
FOREIGN KEY(room_id) REFERENCES Room(room_id) ON DELETE CASCADE ON UPDATE CASCADE
      );`;


// 用来维系好友列表
class RoomImageRepository {
    constructor(dao) {
        this.dao = dao;
    }

    createTable() {
        return this.dao.run(dbSchema);
    }

    create(img_path, room_id) {
        return this.dao.run(
            'INSERT INTO RoomImage (img_path, room_id) VALUES (?, ?)',
            [img_path, room_id]);
    }

    update(img_path, room_id) {
        return this.dao.run(
            'UPDATE RoomImage SET img_path = ? WHERE room_id = ?',
            [img_path, room_id]);
    }

    getByRoomId(room_id) {
        return this.dao.get(
            `SELECT * FROM RoomImage WHERE room_id = ?`,
            [room_id]);
    }
}

module.exports = RoomImageRepository;