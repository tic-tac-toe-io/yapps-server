#
# Copyright (c) 2018 T2T Inc. All rights reserved
# https://www.t2t.io
# https://tic-tac-toe.io
# Taipei, Taiwan
#
const STATE_BOOTSTRAPPING = \bootstrap
const STATE_READY = \ready
const STATE_RUNNING = \running

const TYPE_BOOTSTRAP_REQUEST_CONFIGS = \req-worker-configs
const TYPE_BOOTSTRAP_RESPONSE_CONFIGS = \rsp-worker-configs

const message_states = {
  STATE_BOOTSTRAPPING,
  STATE_READY,
  STATE_RUNNING
}

const message_types = {
  TYPE_BOOTSTRAP_REQUEST_CONFIGS,
  TYPE_BOOTSTRAP_RESPONSE_CONFIGS
}

create_message = (state, type, payload={}) ->
  return {state, type, payload}


module.exports = exports = {create_message, message_states, message_types}
