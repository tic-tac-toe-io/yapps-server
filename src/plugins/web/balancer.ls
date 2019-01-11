#
# Copyright (c) 2018 T2T Inc. All rights reserved
# https://www.t2t.io
# https://tic-tac-toe.io
# Taipei, Taiwan
#
{services} = global.ys
{DBG, ERR, WARN, INFO} = services.get_module_logger __filename

module.exports = exports =
  name: \web

  attach: (name, environment, configs, helpers) ->
    INFO "name: #{name}"
    INFO "environment: #{JSON.stringify environment}"
    INFO "configs: #{JSON.stringify configs}"
    return

  init: (p, done) ->
    INFO "init"
    return done!

  fini: (p, done) ->
    return done!
