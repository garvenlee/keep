 const dbSchema = `
      CREATE TABLE IF NOT EXISTS Room (
        room_id INTEGER PRIMARY KEY AUTOINCREMENT,
        room_name TEXT NOT NULL,
        user_id INTEGER NOT NULL,
        room_size INTEGER NOT NULL DEFAULT 1,
        timestamp INTEGER NOT NULL)`;

 // 创建房间时用
 class RoomRepository {
     constructor(dao) {
         this.dao = dao;
     }

     createTable() {
         return this.dao.run(dbSchema);
     }

     create(room_name, user_id, timestamp) {
         timestamp = timestamp || Math.floor(Date.now() / 1000);
         return this.dao.run(
             `INSERT INTO Room (room_name, user_id, timestamp) VALUES (?, ?, ?)`,
             [room_name, user_id, timestamp]);
     }

     getByRoomId(room_id) {
         return this.dao.run(
             `SELECT * FROM Room WHERE room_id = ?`,
             [room_id]);
     }
 }


 module.exports = RoomRepository;