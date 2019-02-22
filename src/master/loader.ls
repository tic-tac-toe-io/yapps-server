#
# Copyright (c) 2018 T2T Inc. All rights reserved
# https://www.t2t.io
# https://tic-tac-toe.io
# Taipei, Taiwan
#

# ---- MASTER ----
#
require! <[path]>
require! <[colors rc debug js-yaml minimist lodash yargs]>
{COLORIZED, PRETTIZE_KVS, PRINT_PRETTY_JSON} = require \../helpers/utils

debug = debug \yapps-server:master:loader

const cwd = process.cwd!
const app_entry = process.argv[1]
const app_dir = path.dirname app_entry
const app_name = path.basename app_dir
const app_entry_short = if app_entry.startsWith cwd then ".#{app_entry.substring cwd.length}" else app_entry

const CMD1 = "node #{app_entry_short} -w 2"
const CMD2 = "node #{app_entry_short} -w $(nproc) -c /etc/#{app_name}/#{app_name}.yml"
const CMD3 = "node #{app_entry_short} -w $(nproc) -- --web.port=3000 --web.upload_storage=file"
const CMD4 = "DEBUG=yapps-server:* node #{app_entry_short} -w $(nproc)"
const JSON1 = "{ web: { port: 3001, upload_storage: 'file' } }"

argv = yargs
  .alias \w, \workers
  .describe \w, "the number of workers to serve"
  .alias \c, \config
  .describe \c, "configuration file to be loaded"
  .default \c, null
  .alias \v, \verbose
  .describe \v, "enable verbose messages"
  .default \v, no
  .alias \h, \help
  .boolean \h
  .demand <[w]>
  .help!
  .epilogue """
    Examples:
      1. Run #{app_name.cyan} with 2 worker processes and .#{app_name}rc as config
          #{CMD1.green}

      2. Run #{app_name.cyan} with all cpu cores, and use a YAML config file in `/etc/#{app_name}`
          #{CMD2.green}

      3. Run #{app_name.cyan} with all cpu cores, and change web port to 3000.
          #{CMD3.green}

      4. Run #{app_name.cyan} with all cpu cores, and enable debug messages for bootstrap phase
          #{CMD4.green}

    Please note, Use `--` to stop parsing flags, and treat rest arguments as patches
    to be applied to the YAML configuration file loaded by the module `rc`. Those
    patch arguments support dot notation to build an object for applying patch.
    For example, following startup command:

      #{CMD3.gray}

    It composes a JSON object #{JSON1.yellow}, and patched to the loaded YAML configuration file.
  """
  .argv


YAML_PARSE = (document) ->
  return js-yaml.safe-load document


APPLY_BOOLEAN = (xs) ->
  for key, value of xs
    xs[key] = yes if value is \true
    xs[key] = no if value is \false
    APPLY_BOOLEAN value if \object is typeof value



class MasterLoader
  (@opts) ->
    self = @
    self.init_env!
    self.init_cmdline_args!

  init_cmdline_args: ->
    self = @
    debug "process:argv %o", process.argv
    {workers, config, verbose} = argv
    args = argv._  # the arguments after `--`
    debug "cmdline:_: %o", args
    args = [] unless args?
    debug "cmdline:workers: %o", workers
    debug "cmdline:config: %o", config
    debug "cmdline:-: %o", argv._
    debug "args: %o", args
    self.verbose = self.environment['verbose'] = verbose
    self.num_of_workers = num = parseInt workers
    throw new Error "invalid worker option: #{workers}" if num === NaN
    debug "num_of_workers: %d", num
    defaults = require \../common/defaults
    debug "defaults: %o", defaults
    overrides = minimist args
    delete overrides['_']
    APPLY_BOOLEAN overrides
    debug "overrides: %o", overrides
    rcargs = if config? then ["--config", config] else []
    rcargs = minimist rcargs
    debug "rcargs: %o", rcargs
    self.templated_configs = templated_configs = lodash.merge {}, (rc app_name, defaults, rcargs, YAML_PARSE), overrides
    filepath = templated_configs['config']
    delete templated_configs['config']
    delete templated_configs['configs']
    delete templated_configs['_']
    debug "templated_configs from %s", filepath
    debug "templated_configs: %o", templated_configs
    PRINT_PRETTY_JSON \configs, templated_configs

  init_env: (work_dir=null, log_dir=null)->
    self = @
    entry = path.basename process.argv[1]
    debug "entry: %o", entry
    process_name = "mst"
    debug "app_name: %o", app_name
    work_dir = "#{app_dir}/work" unless work_dir?
    logs_dir = "#{app_dir}/logs" unless logs_dir?
    now = new Date!
    year = now.getFullYear!
    month = now.getMonth! + 1
    debug "year: %d", year
    debug "month: %d", month
    month = if month < 10 then "0#{month}" else month.toString!
    startup_time = "#{year}#{month}"
    environment = self.environment = {app_name, process_name, app_dir, work_dir, logs_dir, startup_time}
    debug "environment: %o", environment
    return environment

  init: (done) ->
    {environment, templated_configs, num_of_workers, verbose} = self = @
    logger = require \../common/logger
    (logger-err, get-module-logger) <- logger.init -1, environment, templated_configs['logger'], {}, {}
    return done logger-err if logger-err?
    {services} = global.ys
    services.get_module_logger = get-module-logger
    MasterApp = require \./app
    app = self.app = new MasterApp environment, templated_configs, num_of_workers
    (init-err) <- app.init
    return done init-err if init-err?
    logger = get-module-logger process.argv[1]
    return done null, logger, app, null


module.exports = exports = (opts, done) ->
  {loader} = module
  return done "disallow to create duplicated instance of yapps-server(master)" if loader?
  console.log "bootstrapping yapps-server ..."
  loader = module.loader = new MasterLoader opts
  return loader.init done

