#!/usr/bin/env node
'use strict';

const opts = {
    manifest: {}
};

// Write codes here before bootstrapping yapps-server module.
//
var ys = require('../../');

/**
 * The entire startup process of a typical application based
 * on yapps-server (YS): 
 * 
 * 1. master process calls YS.bootstrap() with designated options
 * 2. master process adds plugins to yapps-server in the callback of bootstrap
 * 3. master process calls YS.start() to start load-balance service
 * 4. master process forks several worker processes
 * 5. each worker process calls YS.bootstrap() with designated options
 * 6. each worker process add express/socket.io middlewares in the callback 
 *    of bootstrap
 * 7. each worker process calls YS.start() and starts express web server
 *    to listen 0.0.0.0:0
 * 8. each worker process informs master process it's ready
 * 9. master process starts to listen a port, and dispatch incoming connections
 *    to each worker process by considering their loads
 */
ys.bootstrap(opts, (berr, logger, master=null, web=null) => {
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

    if (master) {
        /**
         * Configure master app (load-balancer) here.
         */
        master.addPlugin(require('echo1'));
        master.addPlugin(require('plugin-example'));
        master.addPlugin(require('./lib/test-plugin1'));
        /**
         * Start service in the process of master app.
         */
        master.start((serr) => {
            if (serr) {
                ERR(serr, "failed to start service...");
                return process.exit(1);
            }
            INFO("ready.");
        });
    }
    else {
        /**
         * Configure worker app (web) here...
         */
        

        /**
         * Inform master process that worker process is fully configured, and
         * waiting to start service...
         */
        web.start(null);
    }
});
