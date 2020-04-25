var routeHandle = require('./route_handle');


var router = function(app) {
    //routes========================== need to stretch
    app.get('/', (req, res) => {
        res.render('index');
    });

    app.get('/user/:userId', (req, res) => {
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

    app.post('/user/check', (req, res) => {
        routeHandle.handleCheck(res, req.body);
    });

    app.post('/image/upload', (req, res) => {
        routeHandle.handleImageUpload(res, req.body);
    });

    app.post('/addContacts', (req, res) => {
        routeHandle.handleMakeFriendReq(res, req.body);
    });
}


module.exports = router;