/*jshint esversion: 6 */
var express = require('express');
var querystring = require('querystring');
var bodyParser = require('body-parser');
// var multer = require('multer');
var routeHandle = require('./routes/route_handle');
// const AppDAO = require('./dao');
// const UserRepository = require('./user_repository');

var app = express();
var server = require("http").createServer(app);
var io = require("socket.io").listen(server);

// List of all connected users
var connectedUsers = [];
var lastTimestamp = 0; // 记录上一次发送信息的时间
var usernames = ["Anonymous", "garvenlee", "jacklin", "sorry"]; //set the template engine ejs
app.set('view engine', 'ejs');
//middlewares
app.use(express.static('public'));
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

//routes========================== need to stretch
app.get('/', (req, res) => {
    res.render('index');
});

app.get('/user/:email', (req, res) => {
    console.log(req.params);
    routeHandle.handleFriendsGet(res, req.params);
});

app.post('/user/login', (req, res) => {
    routeHandle.handleLogin(res, req.body);
});

app.post('/user/register', (req, res) => {
    routeHandle.handleRegister(res, req.body);
});

app.post('/user/reset', (req, res) => {
    routeHandle.handleReset(res, req.body);
});

app.post('/user/forget', (req, res) => {
    routeHandle.handleForget(res, req.body);
});

app.post('/image/upload', (req, res) => {
    routeHandle.handleImageUpload(res, req.body);
});



//Listen on port 3000
// Declare which port server is listening too
server.listen(42300);
console.log('Server started.');

// const nsp = io.of("/chat");
// // socket.io instantiation
// nsp.on("connection", function(socket) {
//     nsp.username = "Anonymous";
//     console.log("someone connected");
//     //listen on new_message
//     nsp.on('send_message', (data) => {
//         //broadcast the new message
//         console.log('receive data.....');
//         // console.log(data.message);
//         io.sockets.emit('new_message', {message : data.message, username : nsp.username});
//     });
// });
// nsp.emit("hi", "everyone!");


//listen on every connection
// io.on('connection', (socket) => {
io.on('connect', (socket) => {
    connectedUsers.push(socket);
    console.log('New user connected');

    //default username
    socket.username = "Anonymous";
    var i = connectedUsers.indexOf(socket) % 4;
    socket.username = usernames[i];

    //listen on change_username
    socket.on('change_username', (data) => {
        socket.username = data.username;
    });

    socket.on('send_info', (data) => {
        // var numId = Number(data) % 4;
        var numId = socket.id;
        console.log("send_info======>" + numId);
        // socket.username = usernames[numId];
    });

    //listen on new_message
    socket.on('send_message', (stream) => {
        //broadcast the new message
        // console.log(data[0]);
        console.log('receive data.....');
        // nowTimestamp = Math.floor(Date.now() / 1000);
        var timestampFlag = ((stream.timestamp - lastTimestamp) > 90);
        console.log('timestampFlag:' + timestampFlag);
        data = { "username": socket.username, "message": stream.message, "timestampFlag": timestampFlag };
        console.log("====>" + data);
        // console.log(data.message);
        lastTimestamp = stream.timestamp;
        console.log(lastTimestamp);
        io.sockets.emit('new_message', data);
        // io.sockets.emit('new_message', {message : data.message, username : socket.username});
    });

    //listen on typing
    socket.on('typing', (data) => {
        socket.broadcast.emit('typing', { username: socket.username });
    });

    socket.on('disconnect', function() {
        console.log('Got disconnect!');

        var i = connectedUsers.indexOf(socket);
        console.log('=======>' + i);
        connectedUsers.splice(i, 1);
    });
});