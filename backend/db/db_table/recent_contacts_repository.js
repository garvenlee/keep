const dbSchema = `CREATE TABLE IF NOT EXISTS RecentContacts (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_one_id INTEGER NOT NULL,
      user_two_id INTEGER NOT NULL,
      FOREIGN KEY (user_one_id) REFERENCES User(user_id) ON DELETE CASCADE ON UPDATE CASCADE,
      FOREIGN KEY (user_two_id) REFERENCES User(user_id) ON DELETE CASCADE ON UPDATE CASCADE,
    );`;

// user_one_id 为发起聊天者
// 用来维系好友列表
class RecentContactsRepository {
    constructor(dao) {
        this.dao = dao;
    }

    createTable() {
        return this.dao.run(dbSchema);
    }

    create(user_one_id, user_two_id) {
        // 发送好友请求，status=0，等待对方回应
        return this.dao.run(
            'INSERT INTO RecentContacts (user_one_id, user_two_id) VALUES( ? , ? )',
            [user_one_id, user_two_id]);
    }

    delete(user_one_id, user_two_id) {
        return this.dao.run(
            `DELETE FROM RecentContacts WHERE user_one_id = ? and user_two_id = ?`,
            [user_one_id, user_two_id]
        );
    }

    getContactsList(user_id) {
        return this.dao.all(
            `SELECT * FROM RecentContacts WHERE user_id = ?`,
            [user_id]);
    }
}

module.exports = FriendShipRepository;