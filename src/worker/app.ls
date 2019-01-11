#
# Copyright (c) 2018 T2T Inc. All rights reserved
# https://www.t2t.io
# https://tic-tac-toe.io
# Taipei, Taiwan
#

# ---- WORKER ----
#
require! <[path]>
require! <[async]>

{services} = global.ys
{DBG, ERR, WARN, INFO} = services.get_module_logger __filename

{COLORIZED, PRETTIZE_KVS, PRINT_PRETTY_JSON, MERGE_JSON_TEMPLATE} = require \../helpers/utils
{BaseApp} = require \../common/baseapp
{create_message, message_states, message_types} = require \../common/message
{STATE_BOOTSTRAPPING, STATE_BOOTSTRAPPED, STATE_READY} = message_states


class WebService
  (@worker, @opts) ->
    return

  start: (done) ->
    return @worker.start done



class WorkerApp extends BaseApp
  (@environment, @templated_configs, @master_settings) ->
    super environment, templated_configs

  init-context: (environment, configs, done) ->
    {context, configs} = self = @
    web = self.web = new WebService self, configs['web']
    context.set \web, web
    return done!

  init-internally: (environment, configs, done) ->
    {master_settings, delegation} = self = @
    INFO "init-internally: configs => #{JSON.stringify configs}"
    (init-ctx-err) <- self.init-context environment, configs
    return done init-ctx-err if init-ctx-err?
    f = (opts, cb) ->
      try
        {name, req, filepath} = opts
        INFO "loading module #{name.yellow} from #{filepath.green} (origin: #{req.gray})"
        m = require filepath
        p = delegation.create-plugin m
        delegation.add-plugin p
        return cb!
      catch error
        return cb error
    (init-plugin-err) <- async.eachSeries master_settings['plugins'], f
    return done init-plugin-err if init-plugin-err?
    done null, self.web
    return process.send create_message STATE_BOOTSTRAPPED

  at-message: (message, connection) ->
    return

  at-start-successful: ->
    INFO "READY".cyan
    return process.send create_message STATE_READY

  at-start-failed: (err) ->
    ERR err, "failed to start"
    return process.exit 1

  start: ->
    {delegation} = self = @
    (err) <- delegation.start
    return self.at-start-failed err if err?
    return self.at-start-successful!

module.exports = exports = WorkerApp