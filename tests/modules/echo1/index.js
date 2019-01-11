module.exports = exports = {
    attach: function (name, environment, configs, helpers) {
        INFO(`${name}: environment => ${JSON.stringify(environment)}`);
        INFO(`${name}: configs => ${JSON.stringify(configs)}`);
        INFO(`${name}: helpers => ${JSON.stringify(helpers)}`);
        return;
    },
    init: function (p, done) {
        return done();
    },
    fini: function (p, done) {
        return done();
    }
};