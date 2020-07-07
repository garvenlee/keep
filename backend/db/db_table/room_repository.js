 const dbSchema = `
      CREATE TABLE IF NOT EXISTS Room (
        room_id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        room_name TEXT NOT NULL,
        room_number TEXT NOT NULL,
        user_id INTEGER NOT NULL,
        room_size INTEGER NOT NULL DEFAULT 1,
        create_at INTEGER NOT NULL)        `;
 // 创建房间时用
 class RoomRepository {
     constructor(dao) {
         this.dao = dao;
     }

     createTable() {
         return this.dao.run(dbSchema);
     }

     create(room_name, room_number, user_id, room_size, create_at) {
         create_at = create_at || Math.floor(Date.now() / 1000);
         return this.dao.run(
             `INSERT INTO Room (room_name, room_number, user_id, room_size, create_at) VALUES (?, ?, ?, ?, ?)`,
             [room_name, room_number, user_id, room_size, create_at]);
     }

     getByRoomId(room_id) {
         return this.dao.get(
             `SELECT * FROM Room WHERE room_id = ?`,
             [room_id]);
     }

     getByUserId(user_id) {
         return this.dao.all(
             `SELECT * FROM Room WHERE user_id = ?`,
             [user_id]
         );
     }

     getByNumber(room_number) {
         return this.dao.get(
             `SELECT * FROM Room WHERE room_number = ?`,
             [room_number]);
     }
 }


 module.exports = RoomRepository;