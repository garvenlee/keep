const dbSchema = `CREATE TABLE IF NOT EXISTS FriendShip (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_one_id INTEGER NOT NULL,
      user_two_id INTEGER NOT NULL,
      status INTEGER NOT NULL DEFAULT '0',
      action_user_id INTEGER NOT NULL,
      FOREIGN KEY (user_one_id) REFERENCES User(user_id) ON DELETE CASCADE ON UPDATE CASCADE,
      FOREIGN KEY (user_two_id) REFERENCES User(user_id) ON DELETE CASCADE ON UPDATE CASCADE
    );`;
// 唯一性没有设置
// 用来维系好友列表
class FriendShipRepository {
    constructor(dao) {
        this.dao = dao;
    }

    createTable() {
        return this.dao.run(dbSchema);
    }

    create(user_one_id, user_two_id, status, action_user_id) {
        // 发送好友请求，status=0，等待对方回应
        return this.dao.run(
            'INSERT INTO FriendShip (user_one_id, user_two_id, status, action_user_id) VALUES( ? , ? , ? , ? )',
            [user_one_id, user_two_id, status, action_user_id]);
    }

    update(user_one_id, user_two_id, status, action_user_id) {
        // 接受好友请求, status=1
        // 拒绝好友请求, status=2
        // 好友请求受阻，status=3
        return this.dao.run(
            `UPDATE FriendShip SET status = ?, action_user_id = ? WHERE user_one_id = ? AND user_two_id = ?`,
            [status, action_user_id, user_one_id, user_two_id]
        );
    }
    delete(user_one_id, user_two_id) {
        return this.dao.run(
            `DELETE FROM FriendShip WHERE user_one_id = ? and user_two_id = ?`,
            [user_one_id, user_two_id]
        );
    }

    getFriendsList(user_id) {
        return this.dao.all(
            `SELECT * FROM FriendShip WHERE (user_two_id = ? or user_one_id = ?) and status = 1`,
            [user_id, user_id]);
    }
}

module.exports = FriendShipRepository;