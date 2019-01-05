#!/usr/bin/env node
'use strict';

var opts = {
    plugins: [],
    defaults: {
        aaa: true,
        bbb: 2,
        ccc: "abc",
        ddd: ["1", "2", "3"]
    }
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