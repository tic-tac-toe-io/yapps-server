#
# Copyright (c) 2018 T2T Inc. All rights reserved
# https://www.t2t.io
# https://tic-tac-toe.io
# Taipei, Taiwan
#

# ---- MASTER ----
#
require! <[path]>
require! <[rc debug js-yaml minimist lodash]>
debug = debug \yapps-server:master:loader


YAML_PARSE = (document) ->
  return js-yaml.safe-load document


class MasterLoader
  (@opts) ->
    self = @
    {app_name} = self.init_env!
    {args} = self.init_cmdline_args!
    defaults = require \../common/defaults
    debug "opts: %o", opts
    defaults = lodash.merge {}, defaults, opts.defaults
    debug "defaults: %o", defaults
    configs = self.configs = rc app_name, defaults, args, YAML_PARSE
    debug "configs: %o", configs

  init_cmdline_args: ->
    self = @
    debug "process:argv %o", process.argv
    argv = require \yargs
      .alias \w, \workers
      .describe \w, "the number of workers to serve"
      .alias \c, \config
      .describe \c, "configuration file to be loaded"
      .default \c, null
      .alias \h, \help
      .boolean \h
      .demand <[w]>
      .help!
      .epilogue """
        hello
      """
      .argv
    {workers, config} = argv
    args = argv._
    debug "cmdline:_: %o", args
    args = [] unless args?
    args = args ++ ["--config", config] if config?
    debug "cmdline:workers: %o", workers
    debug "cmdline:config: %o", config
    debug "cmdline:-: %o", argv._
    debug "args: %o", args
    num = self.num_of_workers = parseInt workers
    throw new Error "invalid worker option: #{workers}" if num === NaN
    debug "num_of_workers: %d", num
    args = minimist args
    return {args}

  init_env: (current_dir=null, work_dir=null, log_dir=null)->
    self = @
    entry = path.basename process.argv[1]
    debug "entry: %o", entry
    if not current_dir?
      # When the entry script is /xxx/sensor-hub/app.ls, then
      # use `/xxx/sensor-hub` as working directory.
      #
      # When the entry script is /xxx/sensor-hub/app/index.js (or index.raw.js),
      # then still use `/xxx/sensor-hub` as working directory.
      #
      current_dir = path.dirname process.argv[1]
      current_dir = path.dirname current_dir unless entry in <[app.ls index.js]>
    app_name = path.basename path.dirname process.argv[1]
    debug "app_name: %o", app_name
    work_dir = "#{current_dir}/work" unless work_dir?
    logs_dir = "#{current_dir}/logs" unless logs_dir?
    now = new Date!
    year = now.getFullYear!
    month = now.getMonth! + 1
    debug "year: %d", year
    debug "month: %d", month
    month = if month < 10 then "0#{month}" else month.toString!
    startup_time = "#{year}#{month}"
    environment = self.environment = {app_name, current_dir, work_dir, logs_dir, startup_time}
    debug "environment: %o", environment
    return environment

  init: (done) ->
    {environment, configs, num_of_workers} = self = @
    logger = require \../common/logger
    (logger-err, get-module-logger) <- logger.init -1, environment, configs['logger'], {}, {}
    return done logger-err if logger-err?
    {services} = global.yac
    services.get_module_logger = get-module-logger
    MasterApp = require \./app
    app = self.app = new MasterApp environment, configs, num_of_workers
    (init-err) <- app.init
    return done init-err if init-err?
    logger = get-module-logger process.argv[1]
    return done null, app, logger


module.exports = exports = (opts, done) ->
  {loader} = module
  return done "disallow to create duplicated instance of yapps-server(master)" if loader?
  loader = module.loader = new MasterLoader opts
  return loader.init done

