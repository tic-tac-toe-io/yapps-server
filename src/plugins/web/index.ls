#
# Copyright (c) 2018 T2T Inc. All rights reserved
# https://www.t2t.io
# https://tic-tac-toe.io
# Taipei, Taiwan
#
require! <[express body-parser express-bunyan-logger multer mkdirp]>
sio = require \socket.io
sioAuth = require \socketio-auth
{services} = global.ys
{DBG, ERR, WARN, INFO} = services.get_module_logger __filename
{logger} = services.get_module_logger! # bunyan instance.
{REST_ERR, REST_DAT} = rest = require \./helpers

FIRST = (req, res, next) ->
  {originalUrl, socket} = req
  {localAddress, localPort, remoteAddress, remotePort, remoteFamily} = socket
  INFO "#{originalUrl} => localAddress: #{localAddress}"
  INFO "#{originalUrl} => localPort: #{localPort}"
  INFO "#{originalUrl} => remoteAddress: #{remoteAddress}"
  INFO "#{originalUrl} => remotePort: #{remotePort}"
  INFO "#{originalUrl} => remoteFamily: #{remoteFamily}"
  next!

const AUTHENTICATE_CALLBACK_FUNCTION = 1
const AUTHENTICATE_USER_OBJECT = 2
const AUTHENTICATE_EXTERNAL_JS_MODULE = 3


class SocketioAuthenticator
  (@namespace, opts) ->
    o = typeof opts
    INFO "ws[#{namespace}] using authenticator with object type => #{o.cyan}"
    if \function is o
      @type = AUTHENTICATE_CALLBACK_FUNCTION
      @func = opts
    else if \object is o
      @type = AUTHENTICATE_USER_OBJECT
      @users = opts
    else if \string is o
      @type = AUTHENTICATE_EXTERNAL_JS_MODULE
      INFO "ws[#{namespace.yellow}] loading external js as authenticator"
      @func = require opts
    else
      throw new Error "ws[#{namespace}] unsupported authenticator opts"

  verify-by-func: (s, username, password, done) ->
    return @func s, username, password, done
  
  verify: (s, username, password, done) ->
    {namespace, users, type} = self = @
    INFO "ws[#{namespace}]: verify user #{username.yellow} with password #{password.red}, in type #{type}"
    return self.verify-by-func s, username, password, done if type isnt AUTHENTICATE_USER_OBJECT
    p = users[username]
    return done new Error "no such user #{username}" unless p?
    return done null, p is password


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

  use-ws: (name, handler, authenticator=null) ->
    @wss_namespaces[name] = {handler, authenticator}

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

  initiate-plugin-wss-namespaces: ->
    {web, io, wss_namespaces} = self = @
    for let name, callbacks of wss_namespaces
      {handler, authenticator} = callbacks
      namespace = io.of name 
      if authenticator?
        a = new SocketioAuthenticator name, authenticator
        post = (s, data) -> return handler s, data.username
        auth = (s, data, cb) -> return a.verify s, data.username, data.password, cb
        opts = authenticate: auth, postAuthenticate: post
        sioAuth namespace, opts
        INFO "ws: add #{name.yellow} (w/ authentication)"
      else
        namespace.on \connection, handler
        INFO "ws: add #{name.yellow} (w/o authentication)"

  init: (done) ->
    {configs} = self = @
    {upload_storage, upload_path} = configs
    opts = if \memory is upload_storage then {storage: multer.memoryStorage!} else {dest: upload_path}
    upload = self.upload = multer opts
    return done! if \memory is upload_storage
    INFO "creating upload directory: #{upload_path.yellow}"
    return mkdirp upload_path, done

  serve: (done) ->
    {web, configs} = self = @
    web = self.web = new express!
    web.set 'trust proxy', true
    # web.use FIRST
    web.use body-parser.json!
    web.use body-parser.urlencoded extended: true
    self.init-logger!
    server = self.server = web.listen 0, \0.0.0.0, ->
      INFO "listening 0.0.0.0:0"
      return done!
    io = self.io = sio server
    self.initiate-plugin-api-endpoints!
    self.initiate-plugin-wss-namespaces!

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
    {upload} = self = @
    {REST_ERR, REST_DAT} = rest
    UPLOAD = upload
    return {REST_ERR, REST_DAT, UPLOAD}


module.exports = exports =
  name: \web

  attach: (name, environment, configs, helpers) ->
    @[name] = new LocalWeb environment, configs, helpers

  init: (p, done) ->
    return p.init done

  fini: (p, done) ->
    return p.fini done

  master: require \./balancer
