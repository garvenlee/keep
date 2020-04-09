const AppDAO = require('../db/db_access/dao');
const UserRepository = require('../db/db_table/user_repository');
const dao = new AppDAO('../db/database.sqlite3');
const userRepo = new UserRepository(dao);
userRepo.getByEmail('root@163.com')
    .then((user) => {
        console.log(user.id, user.username, user.email, user.password);
    })
    .catch((error) => {
        console.log('User has not exist.');
    });