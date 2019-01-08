#!/usr/bin/env node
'use strict';

const opts = {
    manifest: {}
};

/**
 * Write codes here before bootstrapping yapps-server module.
 */

var ys = require('yapps-server')(opts, (berr, app, logger) => {
    if (berr) {
        console.error(`failed to bootstrap yapps-server, ${berr}`);
        process.exit(1);
    }
    /**
     * Write codes here to manipulate yapps-server instance before
     * starting the web service. Here are supported manipulations:
     * 
     *  - add plugin
     *  - add REST api endpoints
     *  - configure server's runtime behaviors
     */
    var { DBG, ERR, WARN, INFO } = logger
    DBG("at bootstrapping");
    INFO("at bootstrapping");
    WARN("at bootstrapping");
    ERR("at bootstrapping");

    app.start((serr) => {
        if (serr) {
            console.error(`failed to start web service`, serr);
            return;
        }
        INFO("ready.");
    });
});