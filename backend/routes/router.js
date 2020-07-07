var routeHandle = require('./route_handle');


var router = function(app) {
    //routes========================== need to stretch
    app.get('/', (req, res) => {
        res.render('index');
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

    app.post('/user/check', (req, res) => {
        routeHandle.handleCheck(res, req.body);
    });

    app.post('/image/upload', (req, res) => {
        routeHandle.handleImageUpload(res, req.body);
    });


    //////////////////////////
    app.get('/note/get/:userId', (req, res) => {
        // console.log(req.params);
        routeHandle.handleNotesGet(res, req.params);
    });

    app.post('/note/sync', (req, res) => {
        routeHandle.handleNoteSync(res, req.body);
    });

    app.post('/note/syncs', (req, res) => {
        routeHandle.handleNotesSync(res, req.body);
    });

    //////////////////////////

    app.get('/todo/get/:userId', (req, res) => {
        // console.log(req.params);
        routeHandle.handleNotesGet(res, req.params);
    });

    app.post('/todo/sync', (req, res) => {
        routeHandle.handleTodoSync(res, req.body);
    });

    app.post('/todo/syncs', (req, res) => {
        routeHandle.handleTodosSync(res, req.body);
    });

    ///////////////////////////

    app.get('/chat/friends/get/:userId', (req, res) => {
        // console.log(req.params);
        routeHandle.handleFriendsGet(res, req.params);
    });

    app.post('/chat/group/get/', (req, res) => {
        routeHandle.handleGroupGet(res, req.body);
    });

    app.get('/chat/groups/get/:userId', (req, res) => {
        // console.log(req.params);
        routeHandle.handleGroupsGet(res, req.params);
    });

    app.get('/chat/messages/get/:userId', (req, res) => {
        routeHandle.handleMessagesGet(res, req.params);
    });
}


module.exports = router;