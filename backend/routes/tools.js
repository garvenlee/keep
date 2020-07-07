/*jshint esversion: 6 */
var random = require('string-random');
var fs = require('fs');
var path = require('path');


function generate_key() {
    "use strict";
    return random(25);
}

function generate_code() {
    "use strict";
    return random(6, { letters: false });
}


var generateUUID = function() {
    var d = new Date().getTime();
    var uuid = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
        var r = (d + Math.random() * 16) % 16 | 0;
        d = Math.floor(d / 16);
        return (c == 'x' ? r : (r & 0x7 | 0x8)).toString(16);
    });
    return uuid;
};


/**
 * 读取路径信息
 * @param {string} path 路径
 */
function getPathStat(path) {
    return new Promise((resolve, reject) => {
        fs.stat(path, (err, stats) => {
            if (err) {
                resolve(false);
            } else {
                resolve(stats);
            }
        });
    })
}

/**
 * 创建路径
 * @param {string} dir 路径
 */
function mkdir(dir) {
    return new Promise((resolve, reject) => {
        fs.mkdir(dir, err => {
            if (err) {
                resolve(false);
            } else {
                resolve(true);
            }
        });
    })
}

/**
 * 路径是否存在，不存在则创建
 * @param {string} dir 路径
 */
async function dirExists(dir) {
    var isExists = await getPathStat(dir);
    //如果该路径且不是文件，返回true
    if (isExists && isExists.isDirectory()) {
        return true;
    } else if (isExists) { //如果该路径存在但是文件，返回false
        return false;
    }
    //如果该路径不存在
    var tempDir = path.parse(dir).dir; //拿到上级路径
    //递归判断，如果上级目录也不存在，则会代码会在此处继续循环执行，直到目录存在
    var status = await dirExists(tempDir);
    var mkdirStatus;
    if (status) {
        mkdirStatus = await mkdir(dir);
    }
    return mkdirStatus;
}

async function saveImage(timestamp, imgData, field) {
    // 保存群头像数据
    console.log('get data from client...........');

    // handle timestamp used to get the path to save image
    var date_ob = new Date(timestamp).toLocaleString().split(' ');
    // console.log(date_ob);
    var date_prefix = date_ob[0].split('-');
    var date_postfix = date_ob[1].split(':');
    var year = date_prefix[0];
    var month = date_prefix[1]
    var day = date_prefix[2];

    var hour = date_postfix[0];

    var img_dir = path.join('./db/images/' + field, year, month, day, hour);
    var img_name = timestamp.toString() + '.jpg';
    await dirExists(img_dir);

    var img_path = path.join(img_dir, img_name);
    var image = imgData.replace(/^data:image\/\w+;base64,/, "");
    var realFile = Buffer.from(image, "base64");
    // console.log(img_path);

    // 保存图片
    fs.writeFile(img_path, realFile, (err) => {
        if (err) {
            console.log('saving picture error....');
            console.log('=======>' + img_path);
        } else {
            console.log('saving picture success.');
        }
    });

    return img_path;
}


// function handleFriendsList(friend)
var MyLog = function(msg, val2) {
    if (val2) {
        console.log(msg, val2);
    } else {
        console.log(msg);
    }
}

module.exports = {
    generate_code: generate_code,
    generate_key: generate_key,
    dirExists: dirExists,
    generateUUID: generateUUID,
    saveImage: saveImage,
    MyLog: MyLog
};