var cluster = require('cluster');
var net = require('net');
var express = require('express');
var sio = require('socket.io');

var port = 3000;
// var num_processes = require('os').cpus().length;
var num_processes = 2;
var commons = {
    name: 'master',
    index: 0
};

if (cluster.isMaster) {
    // MASTER
    var workers = [];
    var spawn = function(i) {
        var w;
        commons.index = commons.index + 1;
        w = workers[i] = cluster.fork();
        w.on('exit', function(code, signal) {
            console.log(`worker[${i}] with pid ${process.pid} and ppid ${process.ppid} is dead, with code ${code}, now respawning...`);
            spawn(i);
        });
        w.on('message', function(message) {
            var evt = message.evt;
            console.log(`master: got message from worker[${i}]: ${typeof(message)}: ${JSON.stringify(message)}`);
        });
    }
    for (var i = 0; i < num_processes; i++) {
        spawn(i);
    }

    var worker_index = function(ip, len) {
        var s = '';
        for (var i = 0, _len = ip.length; i < _len; i++) {
            if (!isNaN(ip[i])) {
                s += ip[i];
            }
        }
        var result = Number(s) % num_processes;
        console.log(`master: give index ${result} to the remote address ${ip}`);
        return result;
    }

    var server = net.createServer({pauseOnConnect: true}, function(connection) {
        console.log(`master: incoming a connection from ${connection.remoteAddress}`);
        var index = worker_index(connection.remoteAddress, num_processes);
        console.log(`master: given index: ${index}`);
        var worker = workers[index];
        worker.send({evt: 'sticky-session:connection'}, connection);
        // worker.send('sticky-session:connection', connection);
    });
    server.on('listening', function() {
        console.log(`master process: listening port ${port}`);
    });
    server.listen(port);
}
else {
    // WORKER
    console.log(`worker process is created: ${process.pid}`);
    console.log(`worker process ${process.pid} shows commons: ${JSON.stringify(commons)}`);
    var app = new express();
    var s = app.listen(0, '0.0.0.0');
    var io = sio(s);

    app.get('/', (req, res) => {
        console.log(`worker process ${process.pid} get '/' request`);
        res.send('okay');
    });

    var sandbox = io.of('/sandbox');
    sandbox.on('connect', (socket) => {
        console.log(`worker process ${process.pid} gets a sio connection for _sandbox_ namespace`);
    });

    io.on('connect', function(socket) {
        console.log(`worker process ${process.pid} gets a sio connection: ${socket.remoteAddress}`);
    });

    process.on('message', function(message, connection) {
        var evt = message.evt;
        if (evt != 'sticky-session:connection') {
            return;
        }
        console.log(`worker process ${process.pid} gets a net connection: ${connection.remoteAddress}`);
        s.emit('connection', connection);
        connection.resume();
    });

    console.log(`worker process ${process.pid} is ready.`);
    commons.name = 'worker';
    commons.index = commons.index + 1;
    process.send({evt: 'ready'});
}