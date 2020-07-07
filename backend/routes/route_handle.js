/*esversion: 6*/
var fs = require('fs');
var path = require('path');
var functools = require('./tools');
var JwtUtil = require('../tools/jwt');

const async = require('async');

const AppDAO = require('../db/db_access/dao');
const UserRepository = require('../db/db_table/user_repository');
const UserImageRepository = require('../db/db_table/user_image_repository');
const FriendShipRepository = require('../db/db_table/friendship_repository');
const MessageRepository = require('../db/db_table/message_repository');
const RoomRepository = require('../db/db_table/room_repository');
const RoomImageRepository = require('../db/db_table/room_image_repository');
const RoomClientRepository = require('../db/db_table/room_client_repository');
const NoteRepository = require('../db/db_table/note_repository.js');
const TodoRepository = require('../db/db_table/todo_repository.js');


// password hash saved
const bcrypt = require('bcryptjs'); //Importing the NPM bcrypt package.
const saltRounds = 10; //We are setting salt rounds, higher is safer.
var salt = bcrypt.genSaltSync(saltRounds);

function handleMessagesGet(res, stream) {
    try {
        var userId = Number(stream.userId);
    } catch (error) {
        console.log('Missing data.');
        res.json({ "error": true, "error_msg": "Missing data." });
        return;
    }
    var dao = new AppDAO('./db/database.sqlite3');
    var msgRepo = new MessageRepository(dao);
    msgRepo.getAllByUserId(userId)
        .then((messages) => {
            if (messages === undefined || messages.length == 0) {
                res.json({ 'error': true, 'error_msg': 'there has not any messages yet.' });
            } else {
                res.json({ 'error': false, 'messages': messages });
            }
        });
}

function handleGroupGet(res, stream) {
    try {
        var { roomNumber, userId } = stream;
    } catch (error) {
        console.log('Missing data.');
        res.json({ "error": true, "error_msg": "Missing data." });
        return;
    }

    var dao = new AppDAO('./db/database.sqlite3');
    var userRepo = new UserRepository(dao);
    var userImageRepo = new UserImageRepository(dao);
    var roomRepo = new RoomRepository(dao);
    var roomClientRepo = new RoomClientRepository(dao);
    var roomImageRepo = new RoomImageRepository(dao);
    var roomInfo = {};

    roomRepo.getByNumber(roomNumber)
        .then((room) => {
            if (room === undefined) {
                res.json({ 'error': true, 'error_msg': 'cannot find the target group.' });
            } else {
                roomImageRepo.getByRoomId(room.room_id)
                    .then((roomImage) => {
                        var roomImageBase64Txt;
                        if (roomImage === undefined) {
                            roomImageBase64Txt = 'null';
                        } else {
                            // console.log('=================>imageTable op');
                            var img_path = roomImage.img_path;
                            var imgData = fs.readFileSync(img_path).toString("base64");
                            roomImageBase64Txt = "data:image/jpg;base64," + imgData;
                        }
                        // 此处应该添加判断room.user_id == userId ?
                        userRepo.getByUserId(room.user_id)
                            .then((user) => {
                                userImageRepo.getByUserId(user.user_id)
                                    .then((userImage) => {
                                        // console.log('enter.......');
                                        var imgBase64;
                                        if (userImage === undefined) {
                                            imgBase64 = 'null';
                                        } else {
                                            var img_path = userImage.img_path;
                                            var imgData = fs.readFileSync(img_path).toString("base64");
                                            imgBase64 = "data:image/jpg;base64," + imgData;
                                        }
                                        // console.log(roomImageBase64Txt.length);
                                        roomInfo["room"] = {
                                            "room_id": room.room_id,
                                            "room_name": room.room_name,
                                            "room_size": room.room_size,
                                            "room_number": room.room_number,
                                            "room_avatar": roomImageBase64Txt,
                                            "create_at": room.create_at,
                                            "user_id": room.user_id,
                                            "username": user.username,
                                            "email": user.email,
                                            "user_avatar": imgBase64,
                                        };
                                        roomInfo["members"] = [];


                                        roomClientRepo.getMemberList(Number(room.room_id))
                                            .then((clients) => {
                                                // console.log(clients);
                                                (function queryClients(IdList) {
                                                    if (IdList.length) {
                                                        var client = IdList[IdList.length - 1];
                                                        if (client.user_id == userId) {
                                                            console.log('client is myself, do not need to add my info in it.');
                                                            roomInfo["members"].push({
                                                                "client_flag": 1,
                                                                "user_id": userId,
                                                                "join_at": client.join_at
                                                            });
                                                            queryClients(IdList.slice(0, -1));
                                                        } else {
                                                            console.log('client is not myself');
                                                            userRepo.getByUserId(client.user_id)
                                                                .then((user) => {
                                                                    userImageRepo.getByUserId(user.user_id)
                                                                        .then((userImage) => {
                                                                            // console.log('enter.......');
                                                                            var imgBase64;
                                                                            if (userImage === undefined) {
                                                                                imgBase64 = 'null';
                                                                            } else {
                                                                                var img_path = userImage.img_path;
                                                                                var imgData = fs.readFileSync(img_path).toString("base64");
                                                                                imgBase64 = "data:image/jpg;base64," + imgData;
                                                                            }
                                                                            roomInfo["members"].push({
                                                                                "client_flag": 0,
                                                                                "user_id": user.user_id,
                                                                                "username": user.username,
                                                                                "email": user.email,
                                                                                "user_avatar": imgBase64,
                                                                                "join_at": client.join_at
                                                                            });
                                                                            queryClients(IdList.slice(0, -1));
                                                                        });
                                                                });
                                                        }
                                                    } else {
                                                        console.log(roomInfo['room']['room_avatar'].length);
                                                        res.json({ 'error': false, 'data': roomInfo });
                                                    }
                                                })(clients);
                                            })
                                    });
                            });;
                    });
            }
        });
}

function handleGroupsGet(res, stream) {
    try {
        var userId = Number(stream.userId);
    } catch (error) {
        console.log('Missing data.');
        res.json({ "error": true, "error_msg": "Missing data." });
        return;
    }
    var dao = new AppDAO('./db/database.sqlite3');
    var userRepo = new UserRepository(dao);
    var userImageRepo = new UserImageRepository(dao);
    var roomRepo = new RoomRepository(dao);
    var roomClientRepo = new RoomClientRepository(dao);
    var roomImageRepo = new RoomImageRepository(dao);
    var roomIdMap = {};

    roomClientRepo.getAllByUserId(Number(userId))
        .then((roomClients) => {
            // console.log(roomClients);
            // var roomList = {};
            var roomIdMap = {};
            console.log('enter the roomClient db query to find which room has myself in...');
            (function queryRoomClients(IdList) {
                if (IdList.length) {
                    var roomClient = IdList[IdList.length - 1];
                    roomRepo.getByRoomId(roomClient.room_id)
                        .then((room) => {
                            roomImageRepo.getByRoomId(room.room_id)
                                .then((roomImage) => {
                                    var roomImageBase64Txt;
                                    if (roomImage === undefined) {
                                        roomImageBase64Txt = 'null';
                                    } else {
                                        var img_path = roomImage.img_path;
                                        var imgData = fs.readFileSync(img_path).toString("base64");
                                        roomImageBase64Txt = "data:image/jpg;base64," + imgData;
                                    }
                                    userRepo.getByUserId(room.user_id)
                                        .then((user) => {
                                            userImageRepo.getByUserId(user.user_id)
                                                .then((userImage) => {
                                                    // console.log('enter.......');
                                                    var imgBase64;
                                                    if (userImage === undefined) {
                                                        imgBase64 = 'null';
                                                    } else {
                                                        var img_path = userImage.img_path;
                                                        var imgData = fs.readFileSync(img_path).toString("base64");
                                                        imgBase64 = "data:image/jpg;base64," + imgData;
                                                    }
                                                    roomIdMap[roomClient.room_id.toString()] = {
                                                        "room_holder": 0,
                                                        "room_name": room.room_name,
                                                        "room_size": room.room_size,
                                                        "room_number": room.room_number,
                                                        "room_avatar": roomImageBase64Txt,
                                                        "create_at": room.create_at,
                                                        "user_id": room.user_id,
                                                        "username": user.username,
                                                        "email": user.email,
                                                        "user_avatar": imgBase64,
                                                        "members": []
                                                    };
                                                    queryRoomClients(IdList.slice(0, -1));
                                                });
                                        });
                                });
                        });
                } else {
                    console.log('enter the room db query to find which room is holdered by myself...');
                    // console.log(roomIdMap);
                    roomRepo.getByUserId(Number(userId))
                        .then((rooms) => {
                            // console.log(rooms);
                            (function queryRoomHolder(IdList) {
                                if (IdList.length) {
                                    var room = IdList[IdList.length - 1];
                                    roomImageRepo.getByRoomId(room.room_id)
                                        .then((roomImage) => {
                                            var roomImageBase64Txt;
                                            if (roomImage === undefined) {
                                                roomImageBase64Txt = 'null';
                                            } else {
                                                // console.log('=================>imageTable op');
                                                var img_path = roomImage.img_path;
                                                var imgData = fs.readFileSync(img_path).toString("base64");
                                                roomImageBase64Txt = "data:image/jpg;base64," + imgData;
                                            }
                                            roomIdMap[room.room_id.toString()] = {
                                                "room_holder": 1,
                                                "room_name": room.room_name,
                                                "room_size": room.room_size,
                                                "room_number": room.room_number,
                                                "room_avatar": roomImageBase64Txt,
                                                "create_at": room.create_at,
                                                "user_id": userId,
                                                "members": []
                                            };
                                            // console.log(Object.keys(roomIdMap));
                                            queryRoomHolder(IdList.slice(0, -1));
                                        });
                                } else {
                                    // console.log('list: ', roomIdMap);
                                    // res.json({ "error": false, "friends": friendList });
                                    console.log('enter the next step to push clients info...');
                                    var roomIdList = Object.keys(roomIdMap);
                                    // console.log(roomIdList);
                                    (function queryClientInfo(IdMap) {
                                        if (IdMap.length) {
                                            var key = IdMap[IdMap.length - 1];
                                            roomClientRepo.getMemberList(Number(key))
                                                .then((clients) => {
                                                    console.log(clients);
                                                    async.each(clients, function(item, callback) {
                                                        if (item.user_id == userId) {
                                                            console.log('client is myself, do not need to add my info in it.');
                                                            roomIdMap[key]["members"].push({
                                                                "client_flag": 1,
                                                                "user_id": userId,
                                                                "join_at": item.join_at
                                                            });
                                                            callback(null);
                                                            // queryClientInfo(IdMap.slice(0, -1));
                                                        } else {
                                                            console.log('client is not myself');
                                                            userRepo.getByUserId(item.user_id)
                                                                .then((user) => {
                                                                    userImageRepo.getByUserId(user.user_id)
                                                                        .then((userImage) => {
                                                                            // console.log('enter.......');
                                                                            var imgBase64;
                                                                            if (userImage === undefined) {
                                                                                imgBase64 = 'null';
                                                                            } else {
                                                                                var img_path = userImage.img_path;
                                                                                var imgData = fs.readFileSync(img_path).toString("base64");
                                                                                imgBase64 = "data:image/jpg;base64," + imgData;
                                                                            }
                                                                            roomIdMap[key]["members"].push({
                                                                                "client_flag": 0,
                                                                                "user_id": user.user_id,
                                                                                "username": user.username,
                                                                                "email": user.email,
                                                                                "user_avatar": imgBase64,
                                                                                "join_at": item.join_at
                                                                            });
                                                                            callback(null);
                                                                            // queryClientInfo(IdMap.slice(0, -1));
                                                                        });
                                                                });
                                                        }
                                                    }, function(err) {
                                                        // console.log('error==========>');
                                                        // console.log(err);
                                                        // console.log(roomIdMap['11']['members']);
                                                        queryClientInfo(IdMap.slice(0, -1));
                                                    });
                                                });
                                        } else {
                                            // console.log('========================> clients');
                                            // console.log(roomIdMap['1']['members']);
                                            if (Object.keys(roomIdMap).length == 0) {
                                                res.json({ 'error': true, 'error_msg': 'still has not any group yet.' });
                                            } else {
                                                // console.log('return the group list.................');
                                                // console.log(roomIdMap);
                                                // console.log(roomIdMap['11']['members'].length);
                                                res.json({ 'error': false, 'rooms': roomIdMap });
                                            }
                                        }
                                    })(roomIdList);
                                }
                            })(rooms);
                        });
                }
            })(roomClients);
        });
}


function handleFriendsGet(res, stream) {
    try {
        var userId = Number(stream.userId);
    } catch (error) {
        console.log('Missing data.');
        res.json({ "error": true, "error_msg": "Missing data." });
        return;
    }
    // console.log(userId);
    var dao = new AppDAO('./db/database.sqlite3');
    var userRepo = new UserRepository(dao);
    var friendShipRepo = new FriendShipRepository(dao);
    var userImageRepo = new UserImageRepository(dao);
    var friendIdList = [];
    var friendList = [];
    friendShipRepo.getFriendsList(userId).then((friends) => {
        if (friends === undefined || friends.length === 0) {
            console.log('has not any friend yet.');
            res.json({ 'error': true, 'error_msg': 'still has not any friend yet.' });
        } else {
            // console.log(friends);
            friends.forEach((friend) => {
                if (friend.user_one_id === userId) {
                    friendIdList.push(friend.user_two_id);
                } else {
                    friendIdList.push(friend.user_one_id);
                }
                // console.log(friendIdList);
            });
            // console.log(friendIdList);
            // use callback to handle async event but not loop
            (function loopCallback(IdList) {
                if (IdList.length) {
                    // console.log(IdList);
                    userRepo.getByUserId(IdList[IdList.length - 1])
                        .then((user) => {
                            // console.log(user);
                            userImageRepo.getByUserId(user.user_id)
                                .then((userImage) => {
                                    // console.log('enter.......');
                                    var imgBase64;
                                    if (userImage === undefined) {
                                        imgBase64 = 'null';
                                    } else {
                                        var img_path = userImage.img_path;
                                        var imgData = fs.readFileSync(img_path).toString("base64");
                                        imgBase64 = "data:image/jpg;base64," + imgData;
                                    }
                                    friendList.push({
                                        "userId": user.user_id,
                                        "username": user.username,
                                        "email": user.email,
                                        "phone": user.phone,
                                        "avatar": imgBase64
                                    });
                                    loopCallback(IdList.slice(0, -1));
                                });
                        });
                } else {
                    // console.log('list: ', friendList);
                    res.json({ "error": false, "friends": friendList });
                }
            })(friendIdList);
        }
    });
}

function handleLogin(res, stream) {
    try {
        var { email, password } = stream;
    } catch (error) {
        console.log('Missing data.');
        res.json({ "error": true, "error_msg": "Missing data." });
        return;
    }
    // console.log(stream);
    var dao = new AppDAO('./db/database.sqlite3');
    var userRepo = new UserRepository(dao);
    var userImageRepo = new UserImageRepository(dao);

    userRepo.getByEmail(email)
        .then((user) => {
            if (user === undefined) {
                console.log('User has not exist.');
                res.json({
                    "error": true,
                    "error_msg": "User has not exist."
                });
            } else {
                if (vfglobal.socket_Map.hasOwnProperty(user.user_id)) {
                    res.json({
                        "error": true,
                        "error_msg": "Detect Repeat Login."
                    });
                } else {
                    var response = bcrypt.compareSync(password, user.password);
                    // response == true if they match
                    if (response) {
                        // login sucess => generate token
                        var jwt = new JwtUtil(user.user_id.toString());
                        var token = jwt.generateToken();
                        userImageRepo.getByUserId(user.user_id)
                            .then((userImage) => {
                                var imgBase64;
                                if (userImage === undefined) {
                                    imgBase64 = 'null';
                                } else {
                                    var img_path = userImage.img_path;
                                    var imgData = fs.readFileSync(img_path).toString("base64");
                                    imgBase64 = "data:image/jpg;base64," + imgData;
                                }
                                // console.log(user.user_id);
                                // console.log(imgBase64);

                                res.json({
                                    "error": false,
                                    "token": token,
                                    "user": {
                                        "user_id": user.user_id.toString(),
                                        "username": user.username,
                                        "email": user.email,
                                        "password": user.password,
                                        "api_key": user.api_key,
                                        "phone": user.phone,
                                        "user_pic": imgBase64
                                    },
                                });
                            });
                    } else {
                        res.json({
                            "error": true,
                            "error_msg": "Invalid credentitals"
                        });
                    }
                }
            }
        });
}

function handleRegister(res, stream) {
    try {
        var { username, email, password, phone } = stream;
    } catch (error) {
        console.log('Missing data.');
        res.json({ "error": true, "error_msg": "Missing data." });
        return;
    }
    // var api_key = functools.generate_key();
    var api_key = functools.generateUUID();

    var dao = new AppDAO('./db/database.sqlite3');
    var userRepo = new UserRepository(dao);
    console.log(email);
    userRepo.getByEmail(email)
        .then((user) => {
            if (user === undefined) {
                var hash = bcrypt.hashSync(password, salt);
                userRepo.create(username, email, hash, api_key, phone)
                    .then((user) => {
                        if (user === undefined) {
                            res.json({ 'error': true, 'error_msg': 'Error in User Table Operation .' })
                        } else {
                            res.json({ 'error': false, "hint_msg": "You have registered successfully!" });
                        }
                    });
            } else {
                res.json({ 'error': true, "error_msg": "User has exist!" });
            }
        });
}

function handleReset(res, stream) {
    try {
        var { email, password } = stream;
    } catch (error) {
        console.log('Missing data.');
        res.json({ "error": true, "error_msg": "Missing data." });
        return;
    }
    var dao = new AppDAO('./db/database.sqlite3');
    var userRepo = new UserRepository(dao);
    var username;
    userRepo.getByEmail(email)
        .then((user) => {
            if (user === undefined) {
                console.log('User has not exist.');
                res.json({
                    "error": true,
                    "error_msg": "Email is invalid!"
                });
            } else {
                console.log('reset password..............');
                username = user.username;
                var hash = bcrypt.hashSync(password, salt);
                userRepo.update(email, hash)
                    .then((user) => {
                        // user = {id:0}
                        if (user === undefined) {
                            console.log('failed');
                            res.json({
                                'error': true,
                                'error_msg': 'Error in User Table Operation.'
                            });
                        } else {
                            console.log('success');
                            res.json({
                                "error": false,
                                "username": username
                            });
                        }
                    });
            }
        });
}

function handleCheck(res, stream) {
    try {
        var { email } = stream;
    } catch (error) {
        console.log('Missing data.');
        res.json({ "error": true, "error_msg": "Missing data." });
        return;
    }
    var dao = new AppDAO('./db/database.sqlite3');
    var userRepo = new UserRepository(dao);

    userRepo.getByEmail(email)
        .then((user) => {
            if (user === undefined) {
                console.log('error......');
                res.json({
                    "error": true,
                    "error_msg": "Email is invalid!"
                });
            } else {
                console.log(user);
                var code = functools.generate_code();
                res.json({
                    "error": false,
                    "verification_code": code
                });
            }
        });
}


async function handleImageUpload(res, stream) {
    try {
        var { imageData, userId, timestamp } = stream;
    } catch (error) {
        console.log('Missing data.');
        res.json({ "error": true, "error_msg": "Missing data." });
        return;
    }

    var dao = new AppDAO('./db/database.sqlite3');
    var userImageRepo = new UserImageRepository(dao);
    userId = Number(userId);
    functools.saveImage(timestamp, imageData, 'users').then((img_path) => {
        // 更新数据库
        userImageRepo.getByUserId(userId)
            .then((image) => {
                if (image === undefined) {
                    console.log('create.........................');
                    console.log(img_path);
                    userImageRepo.create(img_path, userId)
                        .then((image) => {
                            console.log('enter....');
                            if (image === undefined) {
                                console.log('image table op error.');
                                res.json({
                                    "error": true,
                                    "error_msg": "Error in Image Table Operation ."
                                });
                            } else {
                                res.json({
                                    'error': false,
                                    "hint_msg": "Picture was uploaded successfully."
                                });
                            }
                        });

                } else {
                    console.log('update........................');
                    userImageRepo.update(img_path, userId)
                        .then((image) => {
                            console.log('enter....');
                            if (image === undefined) {
                                console.log('image table op error.');
                                res.json({
                                    "error": true,
                                    "error_msg": "Error in Image Table Operation ."
                                });
                            } else {
                                res.json({
                                    'error': false,
                                    "hint_msg": "Picture was uploaded successfully."
                                });
                            }
                        });

                }
            });
    });

}


function handleNotesGet(res, stream) {
    try {
        var userId = Number(stream.userId);
    } catch (error) {
        console.log('Missing data.');
        res.json({ "error": true, "error_msg": "Missing data." });
        return;
    }
    var dao = new AppDAO('./db/database.sqlite3');
    var noteRepo = new NoteRepository(dao);
    var notesList = [];
    noteRepo.getAllByUserId(userId)
        .then((notes) => {
            if (notes === undefined || notes.length === 0) {
                console.log('has not any note yet.');
                res.json({ 'error': true, 'error_msg': 'still has not any note yet.' });
            } else {
                notes.forEach((note) => {
                    notesList.push({
                        'note_id': note.note_id,
                        'user_id': note.user_id,
                        'title': note.title,
                        'content': note.content,
                        'color': note.color,
                        'state': note.state,
                        'created_at': note.created_at,
                        'modified_at': note.modified_at
                    });
                });
                res.json({ 'error': false, 'notes': notesList })
            }
        });
}


function handleNoteSync(res, stream) {
    console.log('begin to sync one note');
    try {
        var { note, is_new_one } = stream;
    } catch (error) {
        console.log('Missing data.');
        res.json({ "error": true, "error_msg": "Missing data." });
        return;
    }
    // console.log('json decode is ');
    // console.log(note);
    // note to json
    var { note_id, user_id, title, content, tag, color, state, created_at, modified_at } = note;

    var dao = new AppDAO('./db/database.sqlite3');
    var noteRepo = new NoteRepository(dao);
    if (is_new_one) {
        // console.log('create new note');
        noteRepo.create(user_id, title, content, tag, color, state, created_at, modified_at)
            .then((data) => {
                if (data === undefined) {
                    console.log('NoteTable update op error.');
                    res.json({ 'error': true, 'error_msg': 'error op' });
                } else {
                    // console.log('new note');
                    // console.log(data);
                    res.json({ 'error': false, 'note_id': data.id });
                }
            });
    } else {
        // console.log('sync note state is ', state);
        // console.log('sync note id is ', note_id);
        noteRepo.syncNote(user_id, created_at, title, content, tag, color, state, modified_at)
            .then((data) => {
                if (data === undefined) {
                    console.log('NoteTable update op error.');
                    res.json({ 'error': true, 'error_msg': 'error op' });
                } else {
                    // console.log('sync note id is ', data.id); // 0
                    res.json({ 'error': false, 'note_id': note_id });
                }
            });
    }
}

function handleNotesSync(res, stream) {
    console.log('begin to sync all notes');
    try {
        var { uid, offline_notes } = stream;
    } catch (error) {
        console.log('Missing data.');
        res.json({ "error": true, "error_msg": "Missing data." });
        return;
    }
    // console.log(offline_notes);
    var res_notes = [];
    var err_notes = [];
    var dao = new AppDAO('./db/database.sqlite3');
    var noteRepo = new NoteRepository(dao);
    noteRepo.getAllByUserId(uid)
        .then((notes) => {
            notes.forEach((note) => {
                var idx = offline_notes.findIndex(item => {
                    return item.note_id == note.note_id;
                });
                if (idx == -1)
                    res_notes.push(note);
            });
            // console.log(res_notes);
            async.each(offline_notes, function(item, callback) {
                // console.log('item state is ', item.state);
                noteRepo.syncNote(item.user_id, item.created_at, item.title, item.content, item.tag, item.color, item.state, item.modified_at)
                    .then((data) => {
                        if (data === undefined) {
                            err_notes.push(item.note_id);
                        } else {
                            console.log('success sync one item');
                        }
                        callback(null);
                    });
            }, function(err) {
                // console.log(err);
                if (err) {
                    res.json({ 'error': true, 'error_msg': 'unknown error' });
                } else {
                    // console.log(err_notes);
                    // console.log(res_notes);
                    res.json({
                        'error': false,
                        'data': {
                            'res_notes': res_notes,
                            'err_notes': err_notes
                        }
                    });
                }
            });
        });
}

//////////////////////////

function handleTodosGet(res, stream) {
    try {
        var userId = Number(stream.userId);
    } catch (error) {
        console.log('Missing data.');
        res.json({ "error": true, "error_msg": "Missing data." });
        return;
    }
    var dao = new AppDAO('./db/database.sqlite3');
    var todoRepo = new TodoRepository(dao);
    var todosList = [];
    todoRepo.getAllByUserId(userId)
        .then((todos) => {
            if (todos === undefined || todos.length === 0) {
                console.log('has not any todo yet.');
                res.json({ 'error': true, 'error_msg': 'still has not any todo yet.' });
            } else {
                todos.forEach((todo) => {
                    todosList.push({
                        'id': todo.id,
                        'user_id': todo.user_id,
                        'discription': todo.discription,
                        'hasupload': todo.hasupload,
                        'ddl': todo.ddl,
                        'isDone': todo.isDone,
                        'tag': todo.tag,

                    });
                });
                res.json({ 'error': false, 'todos': todosList })
            }
        });
}


function handleTodoSync(res, stream) {
    console.log('begin to sync one todo');
    try {
        var { todo, is_new_one } = stream;
    } catch (error) {
        console.log('Missing data.');
        res.json({ "error": true, "error_msg": "Missing data." });
        return;
    }
    var { todo_id, user_id, description, tag, ddl, is_done, hasupload, created_at, modified_at } = todo;

    var dao = new AppDAO('./db/database.sqlite3');
    var todoRepo = new TodoRepository(dao);
    if (is_new_one) {
        // console.log('create new note');
        todoRepo.create(user_id, hasupload, description, tag, ddl, is_done, created_at, modified_at)
            .then((data) => {
                if (data === undefined) {
                    console.log('TodoTable update op error.');
                    res.json({ 'error': true, 'error_msg': 'error op' });
                } else {
                    // console.log('new note');
                    // console.log(data);
                    res.json({ 'error': false, 'todo_id': data.id });
                }
            });
    } else {
        // console.log('sync note state is ', state);
        // console.log('sync note id is ', note_id);
        todoRepo.syncTodo(user_id, created_at, description, tag, ddl, is_done, modified_at)
            .then((data) => {
                if (data === undefined) {
                    console.log('TodoTable update op error.');
                    res.json({ 'error': true, 'error_msg': 'error op' });
                } else {
                    // console.log('sync note id is ', data.id); // 0
                    res.json({ 'error': false, 'todo_id': todo_id });
                }
            });
    }
}

function handleTodosSync(res, stream) {
    console.log('begin to sync all notes');
    try {
        var { uid, offline_todos } = stream;
    } catch (error) {
        console.log('Missing data.');
        res.json({ "error": true, "error_msg": "Missing data." });
        return;
    }
    // console.log(offline_notes);
    var res_notes = [];
    var err_notes = [];
    var dao = new AppDAO('./db/database.sqlite3');
    var noteRepo = new NoteRepository(dao);
    noteRepo.getAllByUserId(uid)
        .then((notes) => {
            notes.forEach((note) => {
                var idx = offline_notes.findIndex(item => {
                    return item.note_id == note.note_id;
                });
                if (idx == -1)
                    res_notes.push(note);
            });
            // console.log(res_notes);
            async.each(offline_notes, function(item, callback) {
                // console.log('item state is ', item.state);
                noteRepo.syncNote(item.user_id, item.created_at, item.title, item.content, item.tag, item.color, item.state, item.modified_at)
                    .then((data) => {
                        if (data === undefined) {
                            err_notes.push(item.note_id);
                        } else {
                            console.log('success sync one item');
                        }
                        callback(null);
                    });
            }, function(err) {
                // console.log(err);
                if (err) {
                    res.json({ 'error': true, 'error_msg': 'unknown error' });
                } else {
                    // console.log(err_notes);
                    // console.log(res_notes);
                    res.json({
                        'error': false,
                        'data': {
                            'res_notes': res_notes,
                            'err_notes': err_notes
                        }
                    });
                }
            });
        });
}


////////////////////////



module.exports = {
    handleMessagesGet: handleMessagesGet,
    handleGroupGet: handleGroupGet,
    handleGroupsGet: handleGroupsGet,
    handleFriendsGet: handleFriendsGet,
    handleLogin: handleLogin,
    handleRegister: handleRegister,
    handleReset: handleReset,
    handleCheck: handleCheck,
    handleImageUpload: handleImageUpload,
    handleNotesGet: handleNotesGet,
    handleNoteSync: handleNoteSync,
    handleNotesSync: handleNotesSync,
    handleTodosGet: handleTodosGet,
    handleTodoSync: handleTodoSync,
    handleTodosSync: handleTodosSync,
};