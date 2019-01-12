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
        var echo = new express();
        echo.get('/', (req, res) => {
            var {query, headers} = req;
            res.json({query, headers});
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