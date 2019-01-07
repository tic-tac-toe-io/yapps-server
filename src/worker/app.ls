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

{services} = global.yac
{DBG, ERR, WARN, INFO} = services.get_module_logger __filename

{COLORIZED, PRETTIZE_KVS, PRINT_PRETTY_JSON, MERGE_JSON_TEMPLATE} = require \../helpers/utils
BaseApp = require \../common/baseapp
{create_message, message_states, message_types} = require \../common/message
{STATE_BOOTSTRAPPING, STATE_READY} = message_states


class WorkerApp extends BaseApp
  (@environment, @templated_configs) ->
    super ...

  init-internally: (environment, configs, done) ->
    self = @
    INFO "init-internally: configs => #{JSON.stringify configs}"
    return done!

  at-message: (message, connection) ->
    return

module.exports = exports = WorkerApp