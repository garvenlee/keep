/*esversion: 6*/
var fs = require('fs');
var path = require('path');
var functools = require('./tools');
var JwtUtil = require('../tools/jwt');

const AppDAO = require('../db/db_access/dao');
const UserRepository = require('../db/db_table/user_repository');
const UserImageRepository = require('../db/db_table/image_repository');
const FriendShipRepository = require('../db/db_table/friendship_repository');
const MessageRepository = require('../db/db_table/message_repository');
const RoomRepository = require('../db/db_table/room_repository');
const RoomClientRepository = require('../db/db_table/room_client_repository');
// password hash saved
const bcrypt = require('bcryptjs'); //Importing the NPM bcrypt package.
const saltRounds = 10; //We are setting salt rounds, higher is safer.
var salt = bcrypt.genSaltSync(saltRounds);


function handleFriendsGet(res, stream) {
    try {
        var userId = Number(stream.userId);
    } catch (error) {
        console.log('Missing data.');
        res.json({ "error": true, "error_msg": "Missing data." });
        return;
    }
    console.log(userId);
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
            console.log(friends);
            friends.forEach((friend) => {
                if (friend.user_one_id === userId) {
                    friendIdList.push(friend.user_two_id);
                } else {
                    friendIdList.push(friend.user_one_id);
                }
                console.log(friendIdList);
            });
            console.log(friendIdList);
            // use callback to handle async event but not loop
            (function loopCallback(IdList) {
                if (IdList.length) {
                    // console.log(IdList);
                    userRepo.getByUserId(IdList[IdList.length - 1])
                        .then((user) => {
                            console.log(user);
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
                                    friendList.push({
                                        "userId": user.user_id,
                                        "username": user.username,
                                        "email": user.email,
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
        });
}

function handleRegister(res, stream) {
    try {
        var { username, email, password } = stream;
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
                userRepo.create(username, email, hash, api_key)
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
    userId = Number(userId);
    console.log('get data from client...........');
    var dao = new AppDAO('./db/database.sqlite3');
    var userRepo = new UserRepository(dao);
    var userImageRepo = new UserImageRepository(dao);

    // handle timestamp used to get the path to save image
    var date_ob = new Date(timestamp).toLocaleString().split(' ');
    // console.log(date_ob);
    var date_prefix = date_ob[0].split('-');
    var date_postfix = date_ob[1].split(':');
    var year = date_prefix[0];
    var month = date_prefix[1]
    var day = date_prefix[2];

    var hour = date_postfix[0];

    var img_dir = path.join('./db/images', year, month, day, hour);
    var img_name = timestamp.toString() + '.jpg';
    await functools.dirExists(img_dir);

    var img_path = path.join(img_dir, img_name);
    var image = imageData.replace(/^data:image\/\w+;base64,/, "");
    var realFile = Buffer.from(image, "base64");
    console.log(img_path);



    // 保存图片
    fs.writeFile(img_path, realFile, (err) => {
        if (err) {
            console.log('saving picture error....');
            console.log(img_path + '=======>' + userId);
        } else {
            console.log('saving picture success.');
        }
    });

    // 更新数据库
    userImageRepo.getByUserId(userId)
        .then((image) => {
            if (image === undefined) {
                console.log('create.........................');
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
}

module.exports = {
    handleFriendsGet: handleFriendsGet,
    handleLogin: handleLogin,
    handleRegister: handleRegister,
    handleReset: handleReset,
    handleCheck: handleCheck,
    handleImageUpload: handleImageUpload,
};