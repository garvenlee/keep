const dbSchema = `CREATE TABLE IF NOT EXISTS UserImage (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      img_path TEXT NOT NULL,
      user_id INTEGER NOT NULL,
      FOREIGN KEY(user_id) REFERENCES User(user_id) ON DELETE CASCADE ON UPDATE CASCADE   );`;


// 用来维系好友列表
class UserImageRepository {
    constructor(dao) {
        this.dao = dao;
    }

    createTable() {
        return this.dao.run(dbSchema);
    }

    create(img_path, user_id) {
        // 发送好友请求， status=0，等待对方回应
        // this.dao.run('ALTER TABLE UserImage NOCHECK CONSTRAINT user_id');
        return this.dao.run(
            'INSERT INTO UserImage (img_path, user_id) VALUES (?, ?)',
            [img_path, user_id]);
    }

    update(img_path, user_id) {
        return this.dao.run(
            'UPDATE UserImage SET img_path = ? WHERE user_id = ?',
            [img_path, user_id]);

    }

    getByUserId(user_id) {
        return this.dao.get(
            `SELECT * FROM UserImage WHERE user_id = ?`,
            [user_id]);
    }
}

module.exports = UserImageRepository;