#
# Copyright (c) 2018 T2T Inc. All rights reserved
# https://www.t2t.io
# https://tic-tac-toe.io
# Taipei, Taiwan
#

# ---- MASTER ----
#
require! <[path cluster]>
require! <[async lodash]>

{services} = global.yac
{DBG, ERR, WARN, INFO} = services.get_module_logger __filename

BaseApp = require \../common/baseapp
{create_message, message_states, message_types} = require \../common/message
{STATE_BOOTSTRAPPING, STATE_BOOTSTRAPPED, STATE_READY} = message_states
{TYPE_BOOTSTRAP_REQUEST_CONFIGS, TYPE_BOOTSTRAP_RESPONSE_CONFIGS} = message_types


class Worker
  (@master, @index) ->
    self = @
    self.bootstrapped = no
    self.ready = no
    child = self.child = cluster.fork!
    pid = self.pid = child.process.pid
    child.on \exit, (code, signal) -> return self.at-exit code, signal
    child.on \message, (message) -> return self.at-message message
    prefix = self.prefix = "children[#{index}:#{pid}]"
    INFO "#{prefix}: created, but not ready"
    return

  at-exit: (code, signal) ->
    {child, master, index, prefix} = self = @
    child.removeAllListeners \exit
    child.removeAllListeners \message
    INFO "#{prefix}: got-exit-signal => code:#{code}, signal:#{signal}"
    return master.at-child-exit index, code, signal

  at-message: (message) ->
    {index, prefix} = self = @
    INFO "#{prefix}: got-a-message => #{JSON.stringify message}"
    {state, type, payload} = message
    return self.at-bootstrapped! if state is STATE_BOOTSTRAPPED
    return self.at-bootstrapping-message type, payload if state is STATE_BOOTSTRAPPING

  at-bootstrapping-message: (type, payload) ->
    return @.at-bootstrapping-req-configs payload if type is TYPE_BOOTSTRAP_REQUEST_CONFIGS

  at-bootstrapping-req-configs: (payload) ->
    {master, child, index} = self = @
    templated_configs = lodash.merge {}, master.templated_configs
    environment = lodash.merge {}, master.environment
    environment['process_name'] = if index < 10 then "w0#{index}" else "w#{index}"
    child.send create_message STATE_BOOTSTRAPPING, TYPE_BOOTSTRAP_RESPONSE_CONFIGS, {index, environment, templated_configs}

  at-bootstrapped: ->
    {master, index} = self = @
    self.bootstrapped = yes
    master.at-bootstrapped self, index


class MasterApp extends BaseApp
  #
  # environment
  #   - app_name
  #   - process_name
  #   - app_dir
  #   - work_dir
  #   - logs_dir
  #   - startup_time
  #
  # templated_configs
  #   - load from YAML config file, and merged with command-line options after `--` (support nested json object with dot notation)
  #   - default values are loaded from yapps-server/src/common/defaults.ls
  #   - those handlebar variables (e.g. `{{work_dir}}`) are still kept
  #
  # configs:
  #   - merged configurations, no handlebars variables
  #
  (@environment, @templated_configs, @num_of_workers) ->
    super environment, templated_configs, yes
    @workers = []
    @bootstrapped = no
    @bootstrap-callback = null

  init-internally: (environment, configs, done) ->
    {num_of_workers} = self = @
    self.bootstrap-callback = done
    self.workers = [ (new Worker self, i) for i from 0 to (num_of_workers-1) ]

  at-child-exit: (index, code, signal) ->
    {workers} = self = @
    workers[index] = new Worker self, index

  at-bootstrapped: (worker, index) ->
    {workers, bootstrapped, bootstrap-callback} = self = @
    return if bootstrapped
    xs = [ (if w.bootstrapped then 1 else 0) for w in workers ]
    xs = lodash.sum xs
    return unless xs is workers.length
    self.bootstrap-callback = null
    self.bootstrapped = yes
    return bootstrap-callback!


module.exports = exports = MasterApp