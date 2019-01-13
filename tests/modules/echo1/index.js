var { DBG, ERR, WARN, INFO } = global.ys.services.get_module_logger(__filename);
var express = require('express');

module.exports = exports = {
    attach: function (name, environment, configs, helpers) {
        INFO(`${name}: environment => ${JSON.stringify(environment)}`);
        INFO(`${name}: configs => ${JSON.stringify(configs)}`);
        INFO(`${name}: helpers => ${JSON.stringify(helpers)}`);
        this[name] = {};
        return 'web'
    },
    init: function (p, done) {
        var {web} = this;
        var {REST_ERR, REST_DAT} = web.get_rest_helpers();
        var echo = new express();
        echo.get('/', (req, res) => {
            var {query, headers, socket, ip} = req;
            var {localAddress, localPort, remoteAddress, remotePort, remoteFamily} = socket;
            var socket = {localAddress, localPort, remoteAddress, remotePort, remoteFamily};
            return REST_DAT(req, res, {query, headers, socket, ip});
        });
        echo.post('/', (req, res) => {
            return REST_ERR(req, res, 'resource_not_implemented');
        });
        web.useApi('echo', echo);
        return done();
    },
    fini: function (p, done) {
        return done();
    },
    master: {
        attach: function (name, environment, configs, helpers) {
            INFO(`${name}: environment => ${JSON.stringify(environment)}`);
            INFO(`${name}: configs => ${JSON.stringify(configs)}`);
            INFO(`${name}: helpers => ${JSON.stringify(helpers)}`);
            this[name] = {};
            return;
        },
        init: function (p, done) {
            return done();
        }
    }
};