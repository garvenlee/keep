/*jshint esversion: 6 */
var express = require('express');
var session = require('express-session');
var querystring = require('querystring');
var bodyParser = require('body-parser');
var functools = require('./routes/tools');
const JwtUtil = require('./tools/jwt');

var app = express();
var server = require("http").createServer(app);
var io = require("socket.io").listen(server);

// set heartbeat pack
io.set('heartbeat timeout', 4000);
io.set('heartbeat interval', 2000);

global.vfglobal = {
    // 在线用户
    allUser: [],
    //所有的 token : userId
    token_Map: {},
    //保存所有的 userId ：socket 连接
    socket_Map: {},
    //前端是否登录
    isLogin: -1,
    MyLog: functools.MyLog,
    //io
    io: io,
    // 消息漫游时长, 默认30天（时间戳）
    expired_length: 30 * 24 * 60 * 60 * 1000
};


console.log(vfglobal.socket_Map);

//set the template engine ejs
app.set('view engine', 'ejs');
//middlewares
app.use(express.static('public'));
app.use(session({
    secret: 'mylittleCabin-secret',
    resave: true, // 即使 session 没有被修改，也保存 session 值，默认为 true
    cookie: { maxAge: 35 * 60 * 1000 }, //session和相应的cookie失效过期
    saveUninitialized: true,
    rolling: true //add 刷新页面 session 过期时间重置
}));
//Here we are configuring express to use body-parser as middle-ware.
// app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.urlencoded({ extended: true, limit: "50mb", parameterLimit: 100000 }))
app.use(bodyParser.json({ limit: '50mb', type: 'application/json' }));
app.use(bodyParser.raw());
app.use(bodyParser.text());
// app.use(multer()); // for parsing multipart/form-data


// cros
app.all('*', function(req, res, next) {
    res.header('Access-Control-Allow-Origin', '*');
    res.header('Access-Control-Allow-Headers', 'Content-Type, Content-Length, Authorization, Accept, X-Requested-With , yourHeaderFeild');
    res.header('Access-Control-Allow-Methods', 'PUT, POST, GET, DELETE, OPTIONS');

    if (req.method === 'OPTIONS') {
        res.send(200); /*让options请求快速返回*/
    } else {
        next();
    }
});

// token 验证
app.use(function(req, res, next) {
    // 我这里知识把登陆和注册请求去掉了，其他的多有请求都需要进行token校验
    if (req.url != '/user/login' &&
        req.url != '/user/register' &&
        req.url != '/user/check' &&
        req.url != '/user/reset') {
        let token = req.headers.token;
        let jwt = new JwtUtil(token);
        let result = jwt.verifyToken();
        // 如果考验通过就next，否则就返回登陆信息不正确
        if (result == 'err') {
            console.log(result);
            res.send({ status: 403, msg: '登录已过期,请重新登录' });
            // res.render('login.html');
        } else {
            next();
        }
    } else {
        next();
    }
});


require('./routes/router')(app);
require('./routes/socket')(io);

// Listen on port 3000
server.listen(45390);
console.log('Server started.');