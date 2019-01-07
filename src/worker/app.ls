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

{create_message, message_states, message_types} = require \../common/message
{STATE_BOOTSTRAPPING, STATE_READY} = message_states


class WorkerApp
  # environment
  #   - app_name
  #   - process_name
  #   - app_dir
  #   - work_dir
  #   - logs_dir
  #   - startup_time
  #
  # configs
  #   - load from YAML config file, and merged with command-line options after `--`
  #
  (@environment, @configs) ->
    return

  init: (done) ->
    {environment, configs} = self = @
    INFO "init."
    return done!

  at-message: (message, connection) ->
    return

module.exports = exports = WorkerApp