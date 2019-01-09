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
  (@environment, @templated_configs, @master_context) ->
    super environment, templated_configs

  init-context: (environment, configs, done) ->
    {context, configs} = self = @
    web = self.web = new WebService self, configs['web']
    context.add \web, web
    return done!

  init-internally: (environment, configs, done) ->
    {master_context, context} = self = @
    INFO "init-internally: configs => #{JSON.stringify configs}"
    (init-ctx-err) <- self.init-context environment, configs
    return done init-context-err if init-context-err?
    f = (opts, cb) ->
      try
        {req, filepath} = opts
        INFO "loading module #{req.yellow} from #{filepath.green}"
        m = require filepath
        p = context.create-plugin m
        context.add-plugin p
        return cb!
      catch error
        return cb error
    (init-plugin-err) <- async.eachSeries master_context['plugins'], f
    return done init-plugin-err if init-plugin-err?
    return done null, self.web

  at-message: (message, connection) ->
    return

  start: (done) ->
    return process.send create_message STATE_BOOTSTRAPPED

module.exports = exports = WorkerApp