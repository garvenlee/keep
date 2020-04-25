const dbSchema = `CREATE TABLE IF NOT EXISTS RecentGroups (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER NOT NULL,
      group_id INTEGER NOT NULL,
      FOREIGN KEY (user_id) REFERENCES User(user_id) ON DELETE CASCADE ON UPDATE CASCADE,
      FOREIGN KEY (group_id) REFERENCES Room(room_id) ON DELETE CASCADE ON UPDATE CASCADE,
    );`;

// user_one_id 为发起聊天者
// 用来维系好友列表
class RecentGroupsRepository {
    constructor(dao) {
        this.dao = dao;
    }

    createTable() {
        return this.dao.run(dbSchema);
    }

    create(user_id, group_id) {
        // 发送好友请求，status=0，等待对方回应
        return this.dao.run(
            'INSERT INTO RecentGroups (user_id, group_id) VALUES( ? , ? )',
            [user_id, group_id]);
    }

    delete(user_id, group_id) {
        return this.dao.run(
            `DELETE FROM RecentGroups WHERE user_id = ? and group_id = ?`,
            [user_id, group_id]
        );
    }

    getContactsList(user_id) {
        return this.dao.all(
            `SELECT * FROM RecentGroups WHERE user_id = ?`,
            [user_id]);
    }
}

module.exports = FriendShipRepository;