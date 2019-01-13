#
# Copyright (c) 2018 T2T Inc. All rights reserved
# https://www.t2t.io
# https://tic-tac-toe.io
# Taipei, Taiwan
#
require! <[net]>
{services} = global.ys
{DBG, ERR, WARN, INFO} = services.get_module_logger __filename

{message_types} = require \../../common/message
{TYPE_RUNNING_WEB_CONNECTION_DISPATCH} = message_types



class TcpBalancer
  (@environment, @configs, @helpers) ->
    @counter = 0
    @port = configs.port
    return

  init: (done) ->
    {configs} = self = @
    INFO "initialized..."
    return done!

  set-workers: (@workers) ->
    return

  at-incoming-connection: (c) ->
    {workers, counter, port} = self = @
    self.counter = counter + 1
    index = counter % workers.length
    INFO "port:#{port} => incoming tcp connection, dispatch to workers[#{index}]"
    /*
    {localAddress, localPort, remoteAddress, remotePort, remoteFamily} = c
    INFO "localAddress: #{localAddress}"
    INFO "localPort: #{localPort}"
    INFO "remoteAddress: #{remoteAddress}"
    INFO "remotePort: #{remotePort}"
    INFO "remoteFamily: #{remoteFamily}"
    c.on \close, ->
      INFO "port:#{port}, connection closed"
    */
    return workers[index].dispatch-connection TYPE_RUNNING_WEB_CONNECTION_DISPATCH, c

  serve: (done) ->
    {port} = self = @
    pauseOnConnect = yes
    server = self.server = net.createServer {pauseOnConnect}, (c) -> return self.at-incoming-connection c
    server.on \listening, ->
      INFO "listening port number #{port}"
      return done!
    server.listen port

  fini: (done) ->
    INFO "fini."
    return done!

module.exports = exports =
  name: \web

  attach: (name, environment, configs, helpers) ->
    INFO "name: #{name}"
    @[name] = new TcpBalancer environment, configs, helpers

  init: (p, done) ->
    return p.init done

  fini: (p, done) ->
    return p.fini done
