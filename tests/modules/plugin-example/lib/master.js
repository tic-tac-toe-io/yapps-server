var { DBG, ERR, WARN, INFO } = global.ys.services.get_module_logger(__filename);
INFO("hello");

module.exports = exports = {
    attach: function (name, environment, configs, helpers) {
        INFO(`${name}: environment => ${JSON.stringify(environment)}`);
        INFO(`${name}: configs => ${JSON.stringify(configs)}`);
        INFO(`${name}: helpers => ${JSON.stringify(helpers)}`);
        return ['echo1'];
    },
    init: function (p, done) {
        var {echo1} = this;
        INFO(`init, echo1: ${JSON.stringify(echo1)}`);
        return done();
    },
    fini: function (p, done) {
        return done();
    }
};