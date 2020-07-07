var fs = require('fs');
var path = require('path');
var functools = require('../routes/tools');
const AppDAO = require('../db/db_access/dao');
const UserRepository = require('../db/db_table/user_repository');
const UserImageRepository = require('../db/db_table/user_image_repository');
const FriendShipRepository = require('../db/db_table/friendship_repository');
const FriendShipClientRepository = require('../db/db_table/friendship_client_repository');
const MessageRepository = require('../db/db_table/message_repository');
const MessageClientRepository = require('../db/db_table/message_client_repository');
const RoomRepository = require('../db/db_table/room_repository');
const RoomClientRepository = require('../db/db_table/room_client_repository');
const RoomImageRepository = require('../db/db_table/room_image_repository');

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
    var roomImageRepo = new RoomImageRepository(dao);

    // 拦截操作 通过 token
    io.set("authorization", function(handshakeData, callback) {
        console.log('enter authorization......');
        // vfglobal.MyLog(handshakeData.url);
        // vfglobal.MyLog(handshakeData.headers);
        // vfglobal.MyLog(handshakeData._query);
        var token = handshakeData._query.auth;
        // timestamp 可用于追踪用户登录状态
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
                roomClients.forEach((roomClient) => {
                    socket.join(roomClient.room_id.toString());
                    vfglobal.MyLog("加入群：", roomClient.room_id.toString() + " " + new Date().toLocaleString());
                });
            });

        roomRepo.getByUserId(Number(userId))
            .then((rooms) => {
                rooms.forEach((room) => {
                    socket.join(room.room_id.toString());
                    vfglobal.MyLog("加入群：", room.room_id.toString() + " " + new Date().toLocaleString());
                });
            });

        console.log('begin to send offline message....');
        msgClientRepo.getAllP2PByUserId(Number(userId))
            .then((msgClients) => {
                // console.log(msgClients);
                if (msgClients === undefined || msgClients.length == 0) {
                    socket.emit('chats', { 'error': true });
                } else {
                    var response = [];
                    (function loopCallback(dataList) {
                        if (dataList.length) {
                            var msgClient = dataList[dataList.length - 1];
                            msgRepo.getOneP2PByMsgId(msgClient.msg_id)
                                .then((msg) => {
                                    msgRepo.updateOverIsSended(msg.msg_id);
                                    userRepo.getByUserId(msg.creator_id)
                                        .then((user) => {
                                            response.push({
                                                "chat_type": msg.chat_type,
                                                "message_type": msg.message_type,
                                                "message_body": msg.message_body,
                                                "creator_id": msg.creator_id,
                                                "creator_name": user.username,
                                                "recipient_id": msg.recipient_id,
                                                "create_at": msg.create_at,
                                                "expired_at": msg.expired_at,
                                                "is_offline": 1,
                                                "is_read": 0,
                                            });
                                            loopCallback(dataList.slice(0, -1));
                                        });
                                });
                        } else {
                            socket.emit('chats', { 'error': false, 'messages': response });
                        }
                    })(msgClients);
                }
            }).then(() => {
                msgClientRepo.delete(Number(userId)).then(() => {
                    console.log('delete from MessageClient where recipient_id = ' + userId);
                });
            });

        // 用户A请求B，B不在线，等待B在线时推送
        friendShipRepo.getFriendRequests(Number(userId))
            .then((requests) => {
                var response = [];
                if (requests === undefined || requests.length == 0) {
                    socket.emit('friendRequests', { 'error': true });
                } else {
                    (function loopCallback(dataList) {
                        if (dataList.length) {
                            // console.log(dataList);
                            var item = dataList[dataList.length - 1];
                            friendShipRepo.update(item['user_one_id'], item['user_two_id'], 1, item['user_two_id']);
                            userRepo.getByUserId(item['user_one_id'])
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
                                            response.push({
                                                "friendship_id": item.id,
                                                "userId": user.user_id,
                                                "username": user.username,
                                                "email": user.email,
                                                "phone": user.phone,
                                                "avatar": imgBase64
                                            });
                                            loopCallback(dataList.slice(0, -1));
                                        });
                                });
                        } else {
                            // console.log('list: ', friendList);
                            socket.emit('friendRequests', { 'error': false, 'friends': response });
                        }
                    })(requests);
                }
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
            var { userOneId, twoEmail, phone } = stream;

            if (callback) callback(userOneId.toString() + '->' + twoEmail);
            userRepo.getByEmail(twoEmail)
                .then((userTwo) => {
                    if (userTwo === undefined) {
                        socket.emit('friendRequestAck', { 'status': 404 });
                        vfglobal.MyLog('User do not exist!');
                    } else if (userTwo.phone != phone) {
                        socket.emit('friendRequestAck', { 'status': 403 });
                        vfglobal.MyLog('User Info do not match!');
                    } else {
                        userImageRepo.getByUserId(userTwo.user_id)
                            .then((userTwoImage) => {
                                // console.log('enter.......');
                                var userTwoImgBase64;
                                if (userTwoImage === undefined) {
                                    userTwoImgBase64 = 'null';
                                } else {
                                    var img_path = userTwoImage.img_path;
                                    var imgData = fs.readFileSync(img_path).toString("base64");
                                    userTwoImgBase64 = "data:image/jpg;base64," + imgData;
                                }
                                socket.emit('friendRequestAck', {
                                    'status': 200,
                                    'userTwo': {
                                        'userId': userTwo.user_id,
                                        'email': userTwo.email,
                                        'username': userTwo.username,
                                        'phone': userTwo.phone,
                                        'avatar': userTwoImgBase64
                                    }
                                });
                                if (vfglobal.socket_Map.hasOwnProperty(userTwo.user_id.toString())) {
                                    userRepo.getByUserId(userOneId)
                                        .then((userOne) => {
                                            userImageRepo.getByUserId(userOneId)
                                                .then((userOneImage) => {
                                                    // console.log('enter.......');
                                                    var userOneImgBase64;
                                                    if (userOneImage === undefined) {
                                                        userOneImgBase64 = 'null';
                                                    } else {
                                                        var img_path = userOneImage.img_path;
                                                        var imgData = fs.readFileSync(img_path).toString("base64");
                                                        userOneImgBase64 = "data:image/jpg;base64," + imgData;
                                                    }
                                                    var voIo = vfglobal.socket_Map[userTwo.user_id.toString()];
                                                    friendShipRepo.create(userOneId, userTwo.user_id, 1, userTwo.user_id)
                                                        .then((res) => {
                                                            voIo.emit('friendRequest', {
                                                                'friendship_id': res.id,
                                                                'userOne': {
                                                                    'userId': userOneId,
                                                                    'email': userOne.email,
                                                                    'username': userOne.username,
                                                                    'phone': userOne.phone,
                                                                    'avatar': userOneImgBase64,
                                                                },
                                                                'userTwoId': userTwo.user_id
                                                            });
                                                        });
                                                    vfglobal.MyLog('friends request was sent successfully!');
                                                });
                                        });
                                } else {
                                    friendShipRepo.create(userOneId, userTwo.user_id, 0, userOneId);
                                }
                            });

                    }
                });
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
            var { room_name, room_avatar, user_id, userIdList, timestamp } = stream;
            user_id = Number(user_id);
            timestamp = Number(timestamp);
            var room_size = userIdList.length + 1;

            if (callback) callback(stream.room_name); // 反馈 服务器收到了消息
            var room_number = functools.generate_code(); // 此处应该确保code是唯一的，有待优化
            roomRepo.create(room_name, room_number, user_id, room_size, timestamp)
                .then((room) => {
                    if (room === undefined) {
                        socket.emit('createSuccess', { 'success': false });
                    } else {
                        // console.log(room);
                        socket.join(room.id.toString());
                        socket.emit('createSuccess', {
                            'success': true,
                            'room_id': room.id,
                            'room_number': room_number
                        });

                        // 同时需要通知被加进来的群成员，如果在线需要及时更新列表，如果不在线，等待在线通知
                        // 保存群成员数据
                        userIdList.forEach((userId) => {
                            roomClientRepo.create(room.id, userId, timestamp);
                            if (vfglobal.socket_Map.hasOwnProperty(userId.toString())) {
                                var voIo = vfglobal.socket_Map[userId]; // 取出用户io
                                // 此处应该回传的数据可以进一步优化
                                voIo.emit('addedToRoom', {
                                    'room_name': room_name,
                                    'room_number': room_number,
                                    'room_avatar': room_avatar,
                                    'user_id': user_id,
                                    'userIdList': userIdList
                                });
                                voIo.join(room.id.toString()); // 将用户加入到房间
                            } else {
                                // 将被加入房间信息暂存起来等待用户上线拉取通知
                                console.log('save the added room info waiting to be pull later.');
                            }
                        });

                        // 保存群图像数据到本地
                        functools.saveImage(timestamp, room_avatar, 'rooms').then((img_path) => {
                            // 保存群图像记录到数据库
                            // console.log('create.........................');
                            roomImageRepo.create(img_path, room.id)
                                .then((image) => {
                                    // console.log('enter....');
                                    if (image === undefined) {
                                        console.log('room image table op error.');
                                    } else {
                                        console.log('room image table op success.');
                                    }
                                });

                            // 在房间内广播
                            io.sockets.in(room.id.toString()).emit('GroupChat', { 'room_id': room.id });
                        });
                    }
                });
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
            var sockets = socket.broadcast.to(stream.recipient_id);
            // console.log(sockets);
            // console.log(token);
            // console.log(sockets.nsp.sockets['-dCCB1REgABREyAoAAAA'] == vfglobal.socket_Map[userId]);
            // console.log(vfglobal.socket_Map[userId]);
            sockets.emit('chat', stream);
            // 包括自己
            vfglobal.MyLog('给群 ' + stream.recipient_id + " 发消息");
            // io.sockets.in(stream.recipient_id).emit('chat', stream);
        });

        // 用户下线
        socket.on('disconnect', function(data) {
            console.log(data);
            var userId = vfglobal.token_Map[token];
            // vfglobal.MyLog(vfglobal.allUser);
            vfglobal.MyLog(userId + '下线了 下线时间：' + new Date().toLocaleString());
            // io.emit("offLine", { 'user': userId });
            vfglobal.allUser.findIndex(function(T, number, arr) {
                // console.log(T);
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
            // console.log(creator_id, recipient_id, create_at);
            userRepo.getByUserId(creator_id)
                .then((user) => {
                    if (user) {
                        if (callback) { callback(message); }
                        // 用户在线就直接发送过去
                        // 极端情况，刚刚发送的时候，用户退出？
                        if (vfglobal.socket_Map.hasOwnProperty(recipient_id.toString())) { //私聊
                            var voIo = vfglobal.socket_Map[recipient_id]; //取出对应的io
                            msgRepo.createP2P(message_type, message_body, creator_id, recipient_id, create_at, create_at + vfglobal.expired_length, 1)
                                .then((msg) => {
                                    if (msg) {
                                        msgRepo.getOneP2PByMsgId(msg.id).then((msg) => {
                                            var stream = {
                                                // "msg_id": msg.msg_id,
                                                "chat_type": msg.chat_type,
                                                "message_type": msg.message_type,
                                                "message_body": msg.message_body,
                                                "creator_id": msg.creator_id,
                                                "creator_name": user.username,
                                                "recipient_id": msg.recipient_id,
                                                "create_at": msg.create_at,
                                                "expired_at": msg.expired_at,
                                                "is_offline": 0,
                                                "is_read": 0
                                            };
                                            voIo.emit('chat', stream);
                                            vfglobal.MyLog('online sent.');
                                        });
                                    } else {
                                        vfglobal.MyLog('Error in MessageRepository Table Operation Create!');
                                    }
                                });

                        } else {
                            msgRepo.createP2P(message_type, message_body, creator_id, recipient_id, create_at, create_at + vfglobal.expired_length, 0).then((msg) => {
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
                            });
                        }
                    } else {
                        console.log('toUserId ' + recipient_id.toString() + ' is not exists.');
                    }
                })
        }
    });
}

module.exports = chat;