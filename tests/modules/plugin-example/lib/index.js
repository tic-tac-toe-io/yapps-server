/**
 * Copyright (c) 2018 T2T Inc. All rights reserved
 * https://www.t2t.io
 * https://tic-tac-toe.io
 * Taipei, Taiwan
 */

/**
 * Initiate logger functions for this plugin module. Please note, the DBG (DEBUG)
 * function calls don't output to console by default when `-v` is not specified
 * in the command options.
 */
var { DBG, ERR, WARN, INFO } = global.ys.services.get_module_logger(__filename);

/**
 * [TODO] Write down initialization codes here, when the module is loaded by nodejs.
 */
INFO("hello");


/**
 * Plugin declaratiom.
 *  - name, (optional), the name of the plugin.
 *  - attach, the synchronous function to create plugin instance, and attach to app context.
 *  - init, the asynchronous function to initialize the plugin instance.
 *  - fini, (optional), the asynchronous function to finalize the plugin instance when app is shutting down.
 *  - master, (optional), the object to plugin delegation running in the master process.
 */
module.exports = exports = {

    /**
     * The name of this plugin. When the option is not specified, `yapps-server` shall use
     * `name` of package.json or basename of the module as its name. For example,
     * 
     *  0. `/opt/plugins/demo/package.json`, the name field in package.json is `xxx`, then plugin name is `xxx`
     *  1. `/opt/plugins/aaa.js`, the plugin name shall be `aaa`
     *  2. `/opt/plugins/demo/index.js`, the plugin name shall be `demo`
     *  3. `/opt/plugins/demo/lib/index.js`, the plugin name shall be `demo`
     *  4. `/opt/plugins/demo/lib/ccc.js`, the plugin name shall be `ccc`
     */
    name: 'example',

    /**
     * Create a plugin instance, and attach to the app context (this) of calling
     * this function.
     * 
     * @param {string} name the name of this plugin
     * @param {object} environment the process environment context, including these fields:
     *                              - app_name
     *                              - process_name
     *                              - app_dir
     *                              - work_dir
     *                              - logs_dir
     *                              - startup_time
     * @param {object} configs the configurations for this plugin, loaded from given YAML file
     * @param {object} helpers all helper functions for plugin development
     * 
     * @returns {(string|Array)} the dependent plugin(s). it's okay to return null, 
     */
    attach: function (name, environment, configs, helpers) {
        /**
         * Following codes demonstrate to create the instance of plugin `xxx`,
         * and specify its dependencies to another 2 plugins `yyy` and `zzz`.
         */
        // xxx = this[name] = new XxxService(environment, configs);
        // return ['yyy', 'zzz'];
    },

    /**
     * Asynchronously initialize the plugin.
     * 
     * @param {*} p the instance of plugin attached to app context (if any)
     * @param {*} done the callback function to indicate the initialization of plugin is successful or failed.
     */
    init: function (p, done) {
        // var {yyy, zzz} = this;
        return done();
    },

    /**
     * Asynchronously finalize the plugin when the application is shutting down.
     * 
     * @param {*} p the instance of plugin attached to app context (if any)
     * @param {*} done the callback function to indicate the finalization of plugin is successful or failed.
     */
    fini: function (p, done) {
        INFO(`init`);
        return done();
    },

    master: require('./master')
};