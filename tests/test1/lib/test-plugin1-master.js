var { DBG, ERR, WARN, INFO } = global.ys.services.get_module_logger(__filename);
INFO("hello");

module.exports = exports = {
    attach: function(opts, helpers) {
        return;
    },
    init: function(done) {
        return done();
    },
    fini: function(done) {
        return done();
    }
};