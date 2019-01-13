#
# Copyright (c) 2018 T2T Inc. All rights reserved
# https://www.t2t.io
# https://tic-tac-toe.io
# Taipei, Taiwan
#
require! <[express body-parser express-bunyan-logger]>
sio = require \socket.io
{services} = global.ys
{DBG, ERR, WARN, INFO} = services.get_module_logger __filename
{logger} = services.get_module_logger! # bunyan instance.
{REST_ERR, REST_DAT} = rest = require \./helpers

FIRST = (req, res, next) ->
  /*
  INFO "req.url: #{req.originalUrl}"
  INFO "req.ip: #{req.ip}"
  for k, v of req.headers
    INFO "req.headers[#{k}] = #{v}"
  */
  {originalUrl, socket} = req
  {localAddress, localPort, remoteAddress, remotePort, remoteFamily} = socket
  INFO "#{originalUrl} => localAddress: #{localAddress}"
  INFO "#{originalUrl} => localPort: #{localPort}"
  INFO "#{originalUrl} => remoteAddress: #{remoteAddress}"
  INFO "#{originalUrl} => remotePort: #{remotePort}"
  INFO "#{originalUrl} => remoteFamily: #{remoteFamily}"
  next!

class LocalWeb
  (@environment, @configs, @helpers) ->
    @web = new express!
    {api} = configs
    api = [api] unless Array.isArray api
    @routes_general = {}
    @routes_api = {["v#{a}", {}] for a in api}
    @route_api_default = api[0]
    @wss_namespaces = {}
    return

  use: (name, middleware) ->
    @routes_general[name] = middleware

  use-ws: (name, handler) ->
    @wss_namespaces[name] = handler

  use-api: (name, middleware, version=null) ->
    {route_api_default, routes_api} = self = @
    version = route_api_default unless version?
    version = "v#{version}"
    v = routes_api[version]
    return ERR "missing api declaration for version #{version.yellow} when adding middleware #{name.cyan}" unless v?
    v[name] = middleware

  init-logger: ->
    immediate = no
    format = ":remote-address :incoming :method :url HTTP/:http-version :status-code :res-headers[content-length] :referer :user-agent[family] :user-agent[major].:user-agent[minor] :user-agent[os] :response-time ms"
    levelFn = (status, err) ->
      return \debug if status in [200, 201] or 300 <= status < 400
      return \info if 400 <= status < 500
      return \error if status >= 500
      return \warn
    @web.use express-bunyan-logger {logger, immediate, format, levelFn}

  initiate-plugin-api-endpoints: ->
    {web, routes_api} = self = @
    a = self.api = new express!
    for version, routes of routes_api
      v = new express!
      p = "/api/#{version}"
      for let name, middleware of routes
        v.use "/#{name}", middleware
        uri = "#{p}/#{name}"
        INFO "api: add #{uri.yellow}"
      a.use "/#{version}", v
    web.use "/api", a

  init: (done) ->
    {configs} = self = @
    return done!

  serve: (done) ->
    {web, configs} = self = @
    web = self.web = new express!
    web.set 'trust proxy', true
    # web.use FIRST
    web.use body-parser.json!
    web.use body-parser.urlencoded extended: true
    self.init-logger!
    self.initiate-plugin-api-endpoints!
    server = self.server = web.listen 0, \0.0.0.0, ->
      INFO "listening 0.0.0.0:0"
      return done!
    io = self.io = sio server

  fini: (done) ->
    INFO "fini."
    return done!

  at-master-incoming-connection: (connection) ->
    {server} = self = @
    server.emit \connection, connection
    # connection.on \end, -> INFO "connection ended"
    # connection.on \close, -> INFO "connection closed"
    connection.resume!

  get_rest_helpers: ->
    return rest


module.exports = exports =
  name: \web

  attach: (name, environment, configs, helpers) ->
    @[name] = new LocalWeb environment, configs, helpers

  init: (p, done) ->
    return p.init done

  fini: (p, done) ->
    return p.fini done

  master: require \./balancer
