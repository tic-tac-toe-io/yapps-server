var io = require('socket.io-client');
var opts = {
    autoConnect: false,
    transports: ['websocket']
};

// var c = io('https://nuc54250a.t2t.io', opts);
var c = io('https://nuc54250a.t2t.io/sandbox', opts);
// var c = io('http://localhost:3000', opts);
c.on('connected', function() {
    console.log('connected.');
})
c.connect();
return;


