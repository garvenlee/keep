var sqlite3 = require('sqlite3').verbose();

dbSchema = `CREATE TABLE IF NOT EXISTS User(
        id integer NOT NULL PRIMARY KEY AUTOINCREMENT,
        username text NOT NULL UNIQUE,
        email text NOT NULL UNIQUE,
        password text NOT NULL,
        api_key text NOT NULL UNIQUE
    );`

var DB_PATH = 'dataset.sqlite';
const DB = new sqlite3.Database(DB_PATH, function(err) {
    if (err) {
        console.log(err)
        return
    }
    console.log('Connected to ' + DB_PATH + ' database.')
});


DB.exec(dbSchema, function(err) {
    if (err) {
        console.log(err)
    }
    console.log('create User table successfully.')
});

DB.close((err) => {
    if (err) {
        console.error(err.message);
    }
    console.log('Close the database connection.');
});