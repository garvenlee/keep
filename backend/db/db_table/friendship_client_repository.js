const dbSchema = `CREATE TABLE IF NOT EXISTS FriendShipClient (
      client_id INTEGER PRIMARY KEY AUTOINCREMENT,
      friendship_id INTEGER NOT NULL,
      user_one_id INTEGER NOT NULL,
      user_two_id INTEGER NOT NULL,
      status INTEGER NOT NULL,
      FOREIGN KEY (user_one_id) REFERENCES User(user_id) ON DELETE CASCADE ON UPDATE CASCADE,
      FOREIGN KEY (friendship_id) REFERENCES FriendShip(id) ON DELETE CASCADE ON UPDATE CASCADE
    );`;


// 用来维系好友请求离线推送列表
class FriendShipClientRepository {
    constructor(dao) {
        this.dao = dao;
    }

    createTable() {
        return this.dao.run(dbSchema);
    }

    create(friendship_id, user_one_id, user_two_id, status) {
        // 发送好友请求，status=0，等待对方回应
        return this.dao.run(
            'INSERT INTO FriendShipClient (friendship_id, user_one_id, user_two_id, status) VALUES( ? , ?, ?, ? )',
            [friendship_id, user_one_id, user_two_id, status]);
    }

    delete(user_one_id) {
        return this.dao.all(
            `DELETE FROM FriendShipClient WHERE (user_one_id = ?)`,
            [user_one_id]
        );
    }

    getClientItems(user_one_id) {
        return this.dao.all(
            `SELECT * FROM FriendShipClient WHERE user_one_id = ?`,
            [user_one_id]);
    }
}

module.exports = FriendShipClientRepository;