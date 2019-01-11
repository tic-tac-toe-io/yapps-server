#
# Copyright (c) 2018 T2T Inc. All rights reserved
# https://www.t2t.io
# https://tic-tac-toe.io
# Taipei, Taiwan
#
require! <[express]>
sio = require \socket.io
{services} = global.ys
{DBG, ERR, WARN, INFO} = services.get_module_logger __filename


class LocalWeb
  (@environment, @configs, @helpers) ->
    INFO "environment: #{JSON.stringify environment}"
    INFO "configs: #{JSON.stringify configs}"
    @web = new express!
    return

  init: (done) ->
    INFO "init."
    return done!

  serve: (done) ->
    {web, configs} = self = @
    INFO "serve."
    server = self.server = web.listen 0, \0.0.0.0, ->
      INFO "listening 0.0.0.0:0"
      return done!
    io = self.io = sio server

  fini: (done) ->
    INFO "fini."
    return done!



module.exports = exports =
  name: \web

  attach: (name, environment, configs, helpers) ->
    INFO "name: #{name}"
    @[name] = new LocalWeb environment, configs, helpers

  init: (p, done) ->
    return p.init done

  fini: (p, done) ->
    return p.fini done

  master: require \./balancer
