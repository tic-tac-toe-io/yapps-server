#
# Copyright (c) 2018 T2T Inc. All rights reserved
# https://www.t2t.io
# https://tic-tac-toe.io
# Taipei, Taiwan
#
require! <[path handlebars lodash eventemitter2]>
{services} = global.ys
{DBG, ERR, WARN, INFO} = services.get_module_logger __filename
{MERGE_JSON_TEMPLATE} = require \../helpers/utils


class AppPlugin
  (@ad, @req, @filepath, @m) ->
    throw new Error "module for plugin shall not be null" unless m?
    throw new Error "m.attach() shall not be null" unless m.attach?
    throw new Error "m.attach() shall be function but #{typeof m.attach}" unless \function is typeof m.attach
    throw new Error "m.init() shall not be null" unless m.init?
    throw new Error "m.init() shall be function but #{typeof m.init}" unless \function is typeof m.init
    @name = req
    @name = m.name if m.name?
    @name = path.basename path.dirname @name if @name.endsWith "index.js"
    @name = path.basename @name
    @callee = m
    return

  set-callee: (@callee=null) ->
    return @

  to-json: ->
    {req, filepath, name} = self = @
    return {req, filepath, name}


class AppContext
  (@app) ->
    {EventEmitter2} = eventemitter2
    @objects = {}
    @server = new EventEmitter2 do
      wildcard: yes
      delimiter: \::
      newListener: no
      maxListeners: 20
    return

  set: (name, o) ->
    @objects[name] = o

  on: -> return @server.on.apply @server, arguments
  emit: -> return @server.emit.apply @server, arguments
  add-listener: -> return @server.add-listener.apply @server, arguments
  remove-listener: -> return @server.remove-listener.apply @server, arguments
  restart: (evt) -> return @app.restart evt


class AppDelegation
  (@app, @environment, @configs, @context) ->
    @plugins = []
    return

  init: (done) ->
    self = @
    try
      self.hook = hook = require \./require-hook
      hook.install!
    catch error
      return done error
    return done!

  create-plugin: (m) ->
    {hook} = self = @
    result = hook.lookup m
    throw new Error "no such plugin" unless result?
    {id, req, filepath} = result
    p = new AppPlugin self, req, filepath, m
    return p

  add-plugin: (p) ->
    @plugins.push p

  to-json: ->
    {plugins} = self = @
    plugins = [ (p.to-json!) for p in plugins ]
    return {plugins}




class BaseApp
  # Constructor
  #
  # environment
  #   - app_name
  #   - process_name
  #   - app_dir
  #   - work_dir
  #   - logs_dir
  #   - startup_time
  #
  # templated_configs
  #   - load from YAML config file, and merged with command-line options after `--` (support nested json object with dot notation)
  #   - default values are loaded from yapps-server/src/common/defaults.ls
  #   - those handlebar variables (e.g. `{{work_dir}}`) are still kept
  #   - the section `logger` is not in the templated_configs
  #
  #
  (@environment, @templated_configs) ->
    @context = new AppContext @
    @delegation = null
    return

  init-internally: (environment, configs, done) ->
    return done!

  init: (done) ->
    {environment, templated_configs, context} = self = @
    try
      self.configs = configs = MERGE_JSON_TEMPLATE templated_configs, environment
    catch error
      return done error
    d = self.delegation = new AppDelegation self, environment, configs, context
    (err) <- d.init
    return done err if err?
    return self.init-internally environment, configs, done

  start-internally: (done) ->
    return done!

  start: (done) ->
    {configs} = self = @

    return @.start-internally done


module.exports = exports = {BaseApp, AppContext, AppPlugin}
