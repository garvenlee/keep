const dbSchema = `CREATE TABLE IF NOT EXISTS User(
        user_id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        api_key TEXT NOT NULL UNIQUE
    );`;

class UserRepository {
    constructor(dao) {
        this.dao = dao;
    }

    createTable() {
        return this.dao.run(dbSchema);
    }

    create(username, email, password, api_key) {
        return this.dao.run(
            'INSERT INTO User (username, email, password, api_key) VALUES( ? , ? , ? , ? )',
            [username, email, password, api_key]);
    }

    update(user) {
        const { email, password } = user; // dict pack
        return this.dao.run(
            `UPDATE User SET password = ? WHERE email = ?`,
            [email, password]
        );
    }

    delete(email) {
        return this.dao.run(
            `DELETE FROM User WHERE email = ?`,
            [email]
        );
    }

    getByEmail(email) {
        return this.dao.get(
            `SELECT * FROM User WHERE email = ?`,
            [email]);
    }

    getByUsername(username) {
        return this.dao.get(
            `SELECT * FROM User WHERE username = ?`,
            [username]);
    }

    getByUserId(user_id) {
        return this.dao.get(
            `SELECT * FROM User WHERE user_id = ?`,
            [user_id]);
    }

    getAll() {
        return this.dao.all(`SELECT * FROM User`);
    }
}
module.exports = UserRepository;