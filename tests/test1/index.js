#!/usr/bin/env node
'use strict';

var opts = {
    plugins: []
};

var ys = require('yapps-server')(opts, (err, app, logger) => {
    if (err) {
        console.error(`failed to initialize yapps-server, ${err}`);
        process.exit(1);
    }
    /**
     * Write your codes here ...
     */
    var { DBG, ERR, WARN, INFO } = logger
    DBG("ready");
    INFO("ready");
    WARN("ready");
    ERR("ready");
});