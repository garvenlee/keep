var fs = require('fs');


fs.writeFile('./testFs/test/hello,txt', 'hello', function(err) {
    if (err) {
        console.log('error');
        throw err;
    } else {
        console.log('success');
    }
});