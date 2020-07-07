/*jshint esversion: 6 */
var fs = require("fs");
const functools = require('./routes/tools');
// const Promise = require('bluebird');
const AppDAO = require('./db/db_access/dao');
const UserRepository = require('./db/db_table/user_repository');
const UserImageRepository = require('./db/db_table/user_image_repository');
const FriendShipRepository = require('./db/db_table/friendship_repository');
const FriendShipClientRepository = require('./db/db_table/friendship_client_repository');
const MessageRepository = require('./db/db_table/message_repository');
const MessageClientRepository = require('./db/db_table/message_client_repository');
const RoomRepository = require('./db/db_table/room_repository');
const RoomClientRepository = require('./db/db_table/room_client_repository');
const NoteRepository = require('./db/db_table/note_repository');
const TodoRepository = require('./db/db_table/todo_repository');
const RoomImageRepository = require('./db/db_table/room_image_repository');
const RecentContactRepository = require('./db/db_table/recent_contact_repository');
const RecentGroupRepository = require('./db/db_table/recent_group_repository');

var curPath = "./db/database.sqlite3";

function initialTable() {
    const dao = new AppDAO(curPath);
    const userRepo = new UserRepository(dao);
    const userImageRepo = new UserImageRepository(dao);
    const friendShipRepo = new FriendShipRepository(dao);
    const friendClientRepo = new FriendShipClientRepository(dao);
    const messageRepo = new MessageRepository(dao);
    const messageClientRepo = new MessageClientRepository(dao);
    const roomRepo = new RoomRepository(dao);
    const roomClientRepo = new RoomClientRepository(dao);
    const noteRepo = new NoteRepository(dao);
    const todoRepo = new TodoRepository(dao);
    const roomImageRepo = new RoomImageRepository(dao);
    const rcRepo = new RecentContactRepository(dao);
    const rgRepo = new RecentGroupRepository(dao);

    userRepo.createTable();
    friendShipRepo.createTable();
    messageRepo.createTable();
    messageClientRepo.createTable();
    userImageRepo.createTable();
    roomRepo.createTable();
    roomClientRepo.createTable();
    friendClientRepo.createTable();
    noteRepo.createTable();
    todoRepo.createTable();
    roomImageRepo.createTable();
    rcRepo.createTable();
    rgRepo.createTable();
}

initialTable();