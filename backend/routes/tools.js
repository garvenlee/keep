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


// function handleFriendsList(friend)




module.exports = {
    generate_code: generate_code,
    generate_key: generate_key,
    dirExists: dirExists
};