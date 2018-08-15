var express = require('express');
var app = express();

app.get('/', function (req, res) {
    console.log("Got a request to /");
    res.send('OK');
})

app.get('/tag', function (req, res) {
    console.log("Got a request to /tag");
    res.send('OK');
})

var server = app.listen(8080, function () {
    var host = server.address().address
    var port = server.address().port

    console.log("Example app listening at http://%s:%s", host, port)
})