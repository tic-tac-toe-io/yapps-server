#
# Copyright (c) 2018 T2T Inc. All rights reserved
# https://www.t2t.io
# https://tic-tac-toe.io
# Taipei, Taiwan
#

require! <[path]>
require! <[mkdirp bunyan bunyan-debug-stream bunyan-rotating-file-stream lodash debug]>
debug = debug \yapps-server:common:logger


const DEFAULT_PREFIXERS =
  \base : (base) ->
    {module_name, worker_index} = base
    return "master:.:#{(path.basename module_name).gray}" unless worker_index >= 0
    worker_index = "#{worker_index}"
    return "worker:#{worker_index.cyan}:#{(path.basename module_name).gray}"


class ModuleLogger
  (@parent, @worker_index, @module_name) ->
    @logger = @parent.child base: {module_name, worker_index}

  error: -> return @logger.error.apply @logger, arguments
  warn : -> return @logger.warn.apply  @logger, arguments
  info : -> return @logger.info.apply  @logger, arguments
  debug: -> return @logger.debug.apply @logger, arguments


GET_LOGGER = (filename) ->
  {worker_index} = module
  logger = new ModuleLogger module.logger, worker_index, filename
  produce_func = (logger, level) -> return -> logger[level].apply logger, arguments
  return do
    logger: logger.stream
    DBG : produce_func logger, \debug
    ERR : produce_func logger, \error
    WARN: produce_func logger, \warn
    INFO: produce_func logger, \info


module.exports = exports =
  init: (index, environment, configs, prefixers, stringifiers, done) ->
    {app_name, current_dir, work_dir, logs_dir, startup_time} = environment
    debug "index: %o", index
    debug "environment: %o", environment
    debug "configs: %o", configs
    prefixers = lodash.merge {}, DEFAULT_PREFIXERS, prefixers
    stringifiers = lodash.merge {}, stringifiers
    module.worker_index = index
    process_name = if index < 0 then "m0" else "w#{index}"
    debug "process_name: %o", process_name
    logging_dir = "#{logs_dir}/#{startup_time}"
    debug "logging_dir: %o", logging_dir
    (mkdirp-err) <- mkdirp logging_dir
    return done mkdirp-err if mkdirp-err?
    name = app_name
    streams = []
    {serializers} = bunyan-debug-stream
    opts = {name, streams, serializers}
    opts.streams.push do
      level: \info
      type: \raw
      stream: bunyan-debug-stream do
        out: process.stderr
        basepath: current_dir
        forceColor: yes
        showProcess: no
        showDate: (time) -> return time.toISOString!.substring 2
        colors: debug: \gray, info: \white
        prefixers: prefixers
        stringifiers: stringifiers
    opts.streams.push do
      level: \debug
      stream: new bunyan-rotating-file-stream do
        path: "#{logging_dir}/#{name}.#{process_name}.%y-%m-%d.log"
        period: \daily
        rotateExisting: no
        threshold: \1g        # The maximum size for a log file to reach before it's rotated.
        totalFiles: 60        # Keep 60 days (2 months) of log files.
        totalSize: 0
        startNewFile: no
        gzip: yes
    logger = module.logger = bunyan.createLogger opts
    return done null, GET_LOGGER
