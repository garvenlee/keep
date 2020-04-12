/*jshint esversion: 6 */
var fs = require("fs");
const functools = require('./routes/tools');
// const Promise = require('bluebird');
const AppDAO = require('./db/db_access/dao');
const UserRepository = require('./db/db_table/user_repository');
const UserImageRepository = require('./db/db_table/image_repository');
const FriendShipRepository = require('./db/db_table/friendship_repository');
const MessageRepository = require('./db/db_table/message_repository');
const RoomRepository = require('./db/db_table/room_repository');
const RoomClientRepository = require('./db/db_table/room_client_repository');

var curPath = "./db/database.sqlite3";
var usernames = ["root", "admin"];
var email = ["root@163.com", "admin@163.com"];
var password = ["121380316", "121380316"];


function main() {
    const dao = new AppDAO(curPath);
    const userRepo = new UserRepository(dao);
    const userImageRepo = new UserImageRepository(dao);
    const friendShipRepo = new FriendShipRepository(dao);
    const messageRepo = new MessageRepository(dao);
    const roomRepo = new RoomRepository(dao);
    const roomClientRepo = new RoomClientRepository(dao);

    userRepo.createTable()
        .then(() => {
            // userRepo.create(usernames[0], email[0], password[0], functools.generate_key());
            // userRepo.create(usernames[1], email[1], password[1], functools.generate_key());
        })
        .catch((err) => {
            console.log('create userRepo Error.....');
            console.log(JSON.stringify(err));
        });

    friendShipRepo.createTable()
        .then(() => {
            // friendShipRepo.create(1, 2, 0, 1);
            // friendShipRepo.update(1, 2, 1, 2);
        })
        .catch((error) => {
            console.log('create friendShipRepo error.....');
            console.log(JSON.stringify(err));
        });

    messageRepo.createTable()
        .then(() => {
            // messageRepo.createChatRoom('Hello', 1, 0);
            // messageRepo.createChatRoom('Hey', 2, 0);
        })
        .catch((error) => {
            console.log("create messageRepo error.....");
            console.log(JSON.stringify(err));
        });

    userImageRepo.createTable();
    roomRepo.createTable();
    roomClientRepo.createTable();
}



// fs.exists(curPath, function(exists) {
//     if (exists) {
//         fs.unlink(curPath, function(err) {
//             if (err) {
//                 console.log('delete error.....');
//                 throw err;
//             } else {
//                 console.log('delete true');            //             }
//         })
//         // fs.unlinkSync(curPath);
//     }
// });
main();