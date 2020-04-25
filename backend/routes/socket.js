const fs = require('fs');
const AppDAO = require('../db/db_access/dao');
const UserRepository = require('../db/db_table/user_repository');
const UserImageRepository = require('../db/db_table/image_repository');
const FriendShipRepository = require('../db/db_table/friendship_repository');
const FriendShipClientRepository = require('../db/db_table/friendship_client_repository');
const MessageRepository = require('../db/db_table/message_repository');
const MessageClientRepository = require('../db/db_table/message_client_repository');
const RoomRepository = require('../db/db_table/room_repository');
const RoomClientRepository = require('../db/db_table/room_client_repository');

var chat = function(io) {
    var dao = new AppDAO('./db/database.sqlite3');
    var userRepo = new UserRepository(dao);
    var friendShipRepo = new FriendShipRepository(dao);
    var friendClientRepo = new FriendShipClientRepository(dao);
    var userImageRepo = new UserImageRepository(dao);
    var msgRepo = new MessageRepository(dao);
    var msgClientRepo = new MessageClientRepository(dao);
    var roomRepo = new RoomRepository(dao);
    var roomClientRepo = new RoomClientRepository(dao);

    // 拦截操作 通过 token
    io.set("authorization", function(handshakeData, callback) {
        console.log('enter authorization......');
        // vfglobal.MyLog(handshakeData.url);
        // vfglobal.MyLog(handshakeData.headers);
        // vfglobal.MyLog(handshakeData._query);
        var token = handshakeData._query.auth;
        // vfglobal.MyLog(token+"----token");
        // vfglobal.MyLog(vfglobal.token_Map);
        if (token && vfglobal.socket_Map.hasOwnProperty(vfglobal.token_Map[token])) {
            vfglobal.MyLog('repeated connect.');
            callback(null, false);
        } else if (token && vfglobal.token_Map.hasOwnProperty(token)) { //说明存在
            callback(null, true);
        } else {
            if (!token) { //不存在token 拦截
                callback({ data: '不存在token时不能连接' }, false);
                vfglobal.MyLog('拦截连接了');
            } else {
                //查询是否存在
                userRepo.getByApiKey(token)
                    .then((user) => {
                        if (user) {
                            vfglobal.token_Map[token] = user.user_id.toString();
                            callback(null, true);
                            // vfglobal.MyLog('查询后放行 >> 放行连接');
                        } else {
                            callback(null, false); //不存在的token时需要 拦截
                            // vfglobal.MyLog('查询后拦截 >> 拦截连接了');
                        }
                    });
            }
        }
        // vfglobal.MyLog(handshakeData.rawHeaders);
        // vfglobal.MyLog(handshakeData.socket._peername);
        // vfglobal.MyLog(handshakeData.client._peername);
    });

    io.on('connect', function(socket) {
        // console.log(socket.request);
        var token = socket.handshake.query.auth;

        var userId = vfglobal.token_Map[token];

        vfglobal.MyLog("------------------------->" + userId + ' 上线了 上线时间：' + new Date().toLocaleString());

        socket.broadcast.emit('onLine', { 'user': userId });
        // console.log(vfglobal.socket_Map.length);

        vfglobal.socket_Map[userId] = socket; //将用户对应的 socket 存起来
        vfglobal.allUser.push(userId);

        // 此处应该推送好友列表和群列表，且推送最近联系人与离线消息
        console.log('begin to check and join room.....');
        roomClientRepo.getAllByUserId(Number(userId))
            .then((roomClients) => {
                // console.log(roomClients);
                roomClients.forEach((roomClient) => {
                    socket.join(roomClient.room_id.toString());
                    vfglobal.MyLog("加入群：", T.group_name + " " + new Date().toLocaleString());
                });
            });

        console.log('begin to send offline message.....');
        msgClientRepo.getAllP2PByUserId(Number(userId))
            .then((msgClients) => {
                console.log(msgClients);
                msgClients.forEach((msgClient) => {
                    msgRepo.getOneP2PByMsgId(msgClient.msg_id)
                        .then((msg) => {
                            var stream = {
                                "chat_type": msg.chat_type,
                                "message_type": msg.message_type,
                                "message_body": msg.message_body,
                                "creator_id": msg.creator_id,
                                "recipient_id": msg.recipient_id,
                                "create_at": msg.create_at,
                                "expired_at": msg.expired_at,
                                "is_offline": 1
                            };
                            // console.log(stream);
                            socket.emit('chat', stream);
                            vfglobal.MyLog('send offline message.....');
                        });
                });
            }).then(() => {
                msgClientRepo.delete(Number(userId)).then(() => {
                    console.log('delete from MessageClient where recipient_id = ' + userId);
                });
            })

        // 推送好友请求响应消息
        // 此处为极端情况：用户A请求B，B不在线，等待B上线回应时，A也不在线，等待A上线时再推送
        friendClientRepo.getClientItems(Number(userId))
            .then((clients) => {
                clients.forEach((client) => {
                    socket.emit('friendResponse', { 'userTwoId': client.user_two_id, 'status': client.status });
                    vfglobal.MyLog('send offline friend response.');
                    if (client.status === 1) {
                        userRepo.getByUserId(client.user_two_id)
                            .then((user) => {
                                if (user) {
                                    userImageRepo.getByUserId(user.user_id)
                                        .then((userImage) => {
                                            console.log('enter.......');
                                            var imgBase64;
                                            if (userImage === undefined) {
                                                imgBase64 = 'null';
                                            } else {
                                                var img_path = userImage.img_path;
                                                var imgData = fs.readFileSync(img_path).toString("base64");
                                                imgBase64 = "data:image/jpg;base64," + imgData;
                                            }
                                            socket.emit('friendDone', {
                                                "userId": user.user_id,
                                                "username": user.username,
                                                "email": user.email,
                                                "avatar": imgBase64
                                            });
                                        });
                                }
                            });
                    }
                });
            }).then(() => {
                friendClientRepo.delete(Number(userId)).then(() => {
                    console.log('delete from FriendClient where request sender id is ' + userId);
                });
            });

        // 用户A请求B，B不在线，等待B在线时推送
        friendShipRepo.getFriendRequests(Number(userId))
            .then((requests) => {
                requests.forEach((req) => {
                    socket.emit('friendRequest', { 'userOneId': req.user_one_id, 'userTwoId': req.user_two_id });
                    vfglobal.MyLog('send  offline friend request from userId ' + req.user_one_id.toString());
                });
            });


        // 单聊
        socket.on('chat', function(message, callback) {
            // 发送图片
            if (message.type == 'img') {
                console.log('chat convey img......');
            } else if (message.type == 'audio') {
                console.log('chat convey audio......');
            } else if (message.type == 'loc') {
                console.log('chat convey location......');
            } else {
                sendMessage(message, callback);
            }
        });

        socket.on('friendRequest', function(stream, callback) {
            var { userOneId, twoEmail } = stream;

            if (callback) callback(userOneId.toString() + '->' + twoEmail);
            userRepo.getByEmail(twoEmail)
                .then((user) => {
                    if (user) {
                        if (vfglobal.socket_Map.hasOwnProperty(user.user_id.toString())) {
                            var voIo = vfglobal.socket_Map[user.user_id.toString()];
                            voIo.emit('friendRequest', { 'userOneId': userOneId, 'userTwoId': user.user_id });
                            socket.emit('friendRequestAck', { 'status': 303 });
                            vfglobal.MyLog('friends request was sent successfully!');
                        } else {
                            friendShipRepo.create(userOneId, user.user_id, 0, userOneId)
                                .then((res) => {
                                    if (res) {
                                        socket.emit('friendRequestAck', { 'status': 303 });
                                        vfglobal.MyLog('waiting to receive the request.');
                                    } else {
                                        socket.emit('friendRequestAck', { 'status': 304 });
                                        vfglobal.MyLog('Error in FriendShip Table Operation Create!');
                                    }
                                });
                        }
                    } else {
                        socket.emit('friendRequestAck', { 'status': 404 });
                        vfglobal.MyLog('User do not exist!');
                    }
                });
        });

        socket.on('friendResponse', function(stream, callback) {
            // status 0/1/2
            console.log('receiving friend request................');
            var { status, userOneId, userTwoId } = stream;
            if (callback) callback(status.toString() + ' ' + userId.toString);
            if (vfglobal.socket_Map.hasOwnProperty(userOneId.toString())) {
                var voIo = vfglobal.socket_Map[userOneId.toString()];
                voIo.emit('friendResponse', { 'userTwoId': userTwoId, 'status': status });
                vfglobal.MyLog('friend request was received.');
                friendShipRepo.getFriendItem(userOneId, userTwoId)
                    .then((res) => {
                        if (res) {
                            friendShipRepo.update(userOneId, userTwoId, status, userTwoId);
                        } else {
                            friendShipRepo.create(userOneId, userTwoId, status, userTwoId);
                        }
                        if (status === 1) {
                            userImageRepo.getByUserId(userTwoId)
                                .then((userImage) => {
                                    console.log('enter.......');
                                    var imgBase64;
                                    if (userImage === undefined) {
                                        imgBase64 = 'null';
                                    } else {
                                        var img_path = userImage.img_path;
                                        var imgData = fs.readFileSync(img_path).toString("base64");
                                        imgBase64 = "data:image/jpg;base64," + imgData;
                                    }
                                    userRepo.getByUserId(userTwoId)
                                        .then((user) => {
                                            voIo.emit('friendDone', {
                                                "userId": user.user_id,
                                                "username": user.username,
                                                "email": user.email,
                                                "avatar": imgBase64
                                            });
                                        });
                                });
                            userImageRepo.getByUserId(userOneId)
                                .then((userImage) => {
                                    console.log('enter.......');
                                    var imgBase64;
                                    if (userImage === undefined) {
                                        imgBase64 = 'null';
                                    } else {
                                        var img_path = userImage.img_path;
                                        var imgData = fs.readFileSync(img_path).toString("base64");
                                        imgBase64 = "data:image/jpg;base64," + imgData;
                                    }
                                    userRepo.getByUserId(userOneId)
                                        .then((user) => {
                                            socket.emit('friendDone', {
                                                "userId": user.user_id,
                                                "username": user.username,
                                                "email": user.email,
                                                "avatar": imgBase64
                                            });
                                        });
                                });
                        }
                    });
            } else {
                console.log('user was offline, waiting online sending');
                friendShipRepo.getFriendItem(userOneId, userTwoId)
                    .then((res) => {
                        if (res) {
                            friendShipRepo.update(userOneId, userTwoId, status, userTwoId)
                            friendClientRepo.create(res.id, userOneId, userTwoId, status);
                        } else {
                            friendShipRepo.create(userOneId, userTwoId, status, userTwoId)
                                .then((res) => {
                                    friendClientRepo.create(res.id, userOneId, userTwoId, status);
                                });
                        }
                        if (status === 1) {
                            userImageRepo.getByUserId(userOneId)
                                .then((userImage) => {
                                    console.log('enter.......');
                                    var imgBase64;
                                    if (userImage === undefined) {
                                        imgBase64 = 'null';
                                    } else {
                                        var img_path = userImage.img_path;
                                        var imgData = fs.readFileSync(img_path).toString("base64");
                                        imgBase64 = "data:image/jpg;base64," + imgData;
                                    }
                                    userRepo.getByUserId(userOneId)
                                        .then((user) => {
                                            socket.emit('friendDone', {
                                                "userId": user.user_id,
                                                "username": user.username,
                                                "email": user.email,
                                                "avatar": imgBase64
                                            });
                                        });
                                });
                        }
                    });
            }
        });

        //加入群
        socket.on('join', function(stream, callback) {
            var { roomId, userId, timestamp } = stream;
            roomId = Number(roomId);
            userId = Number(userId);
            timestamp = Number(timestamp);

            if (callback) callback(stream.roomId); // 反馈 服务器收到了消息

            roomRepo.getByRoomId(roomId)
                .then((room) => {
                    if (room) {
                        roomClientRepo.create(roomId, userId, timestamp)
                            .then((roomClient) => {
                                if (roomClient) {
                                    socket.join(stream.roomId);
                                    vfglobal.MyLog("加入群： " + stream.roomId);
                                    io.sockets.in(stream.roomId).emit('GroupChat', stream);
                                } else {
                                    vfglobal.MyLog('Error in RoomClient Table Operation Create!');
                                }
                            });
                    } else {
                        vfglobal.MyLog("群不存在： " + stream.roomId);
                    }
                });
        });

        //创建群
        socket.on('create', function(stream, callback) {
            var { room_name, user_id, timestamp } = stream;
            user_id = Number(user_id);
            timestamp = Number(timestamp);

            if (callback) callback(stream.room_name); // 反馈 服务器收到了消息
            roomRepo.create(room_name, user_id, timestamp)
                .then((room) => {
                    if (room) {
                        socket.join(room.room_id.toString());
                        io.sockets.in(room.room_id.toString()).emit('GroupChat', { 'room_id': room.room_id });
                    }
                })
        });

        //退群
        socket.on('leave', function(stream, callback) {
            const { room_id, user_id } = stream;
            roomClientRepo.delete(Number(room_id), Number(user_id))
                .then((roomClient) => {
                    if (roomClient) {
                        vfglobal.MyLog('离开了群：', roomId);
                        socket.leave(roomId);
                    }
                });
        });

        //群聊天
        socket.on('GroupChat', function(stream, callback) {
            // // 不包括自己
            // socket.broadcast.to('group1').emit('event_name', stream);
            // 包括自己
            vfglobal.MyLog('给群 ' + stream.roomId + " 发消息");
            io.sockets.in(stream.roomId).emit('GroupChat', stream);
        });

        // 用户下线
        socket.on('disconnect', function(data) {
            console.log(data);
            var userId = vfglobal.token_Map[token];
            // vfglobal.MyLog(vfglobal.allUser);
            vfglobal.MyLog(userId + '下线了 下线时间：' + new Date().toLocaleString());
            // io.emit("offLine", { 'user': userId });
            vfglobal.allUser.findIndex(function(T, number, arr) {
                console.log(T);
                if (T == userId) {
                    console.log('delete the noted user from allUser');
                    vfglobal.allUser.splice(number, 1);
                    delete vfglobal.socket_Map[userId];
                }
            });
        });

        /*保存数据库，消息应答，消息转发*/
        function sendMessage(message, callback, fileData) {
            var { chat_type, message_type, message_body, creator_id, recipient_id, create_at, is_offline } = message;
            console.log(creator_id, recipient_id, create_at);
            userRepo.getByUserId(recipient_id)
                .then((user) => {
                    if (user) {
                        msgRepo.createP2P(message_type, message_body, creator_id, recipient_id, create_at, create_at + vfglobal.expired_length)
                            .then((msg) => {
                                if (msg) {
                                    if (callback) { callback(message); }
                                    // 用户在线就直接发送过去
                                    // 极端情况，刚刚发送的时候，用户退出？
                                    if (vfglobal.socket_Map.hasOwnProperty(recipient_id.toString())) { //私聊
                                        var voIo = vfglobal.socket_Map[recipient_id]; //取出对应的io
                                        var stream = {
                                            // "msg_id": msg.msg_id,
                                            "chat_type": msg.chat_type,
                                            "message_type": msg.message_type,
                                            "message_body": msg.message_body,
                                            "creator_id": msg.creator_id,
                                            "recipient_id": msg.recipient_id,
                                            "create_at": msg.create_at,
                                            "expired_at": msg.expired_at,
                                            "is_offline": 0
                                        };
                                        voIo.emit('chat', stream);
                                        vfglobal.MyLog('online sent.');
                                    } else {
                                        // 如果用户不在线就缓存进离线推送表
                                        msgClientRepo.createP2P(msg.id, recipient_id)
                                            .then((msgClient) => {
                                                if (msgClient) {
                                                    vfglobal.MyLog('one msg wait to be sent later!');
                                                } else {
                                                    vfglobal.MyLog('Error in MessageClient Table Operation CreateP2P!');
                                                }
                                            });
                                        vfglobal.MyLog('offline sent.');
                                    }
                                } else {
                                    vfglobal.MyLog('Error in MessageRepository Table Operation Create!');
                                }
                            });
                    } else {
                        console.log('toUserId ' + recipient_id.toString() + ' is not exists.');
                    }
                })
        }
    });
}

module.exports = chat;