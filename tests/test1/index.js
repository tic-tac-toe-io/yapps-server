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

    if (app.is_master) {
        /**
         * Configure master app here.
         */
        // app.addPlugin()
        // app.addPlugin()

        /**
         * Start service in the process of master app.
         */
        app.start((serr) => {
            if (serr) {
                ERR(serr, "failed to start service...");
                return process.exit(1);
            }
            INFO("ready.");
        });
    }
    else {
        /**
         * Configure worker app here...
         */
        // app.addPlugin()
        // app.addPlugin()

        /**
         * Inform master process that worker process is fully configured, and
         * waiting to start service...
         */
        app.start(null);
    }
});