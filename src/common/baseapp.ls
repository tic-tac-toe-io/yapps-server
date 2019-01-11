#
# Copyright (c) 2018 T2T Inc. All rights reserved
# https://www.t2t.io
# https://tic-tac-toe.io
# Taipei, Taiwan
#
require! <[path handlebars lodash eventemitter2 debug async]>
{services} = global.ys
{DBG, ERR, WARN, INFO} = services.get_module_logger __filename
{MERGE_JSON_TEMPLATE} = require \../helpers/utils
debug = debug \yapps-server:common:baseapp


DUMMY = (err) ->
  return

##
# Inspired by https://github.com/indexzero/node-pkginfo/blob/master/lib/pkginfo.js
#
LOAD_PACKAGE_JSON = (app_dir, file_path, dir=null) ->
  dir = path.dirname file_path unless dir?
  throw new Error "Could not find package.json up from #{file_path}" if dir is path.dirname dir
  throw new Error "Could not find package.json until app_dir: #{app_dir} from #{file_path}" if dir is app_dir
  throw new Error "Cannot find package.json from unspecified directory" unless dir? or dir is \.
  try
    p = "#{dir}/package.json"
    debug "looking for #{p}"
    json = require p
  catch error
    DUMMY error
  return {p, json} if json?
  return LOAD_PACKAGE_JSON app_dir, file_path, path.dirname dir



class AppPlugin
  (@ad, @req, @filepath, @m) ->
    throw new Error "module for plugin shall not be null" unless m?
    throw new Error "m.attach() shall not be null" unless m.attach?
    throw new Error "m.attach() shall be function but #{typeof m.attach}" unless \function is typeof m.attach
    throw new Error "m.init() shall not be null" unless m.init?
    throw new Error "m.init() shall be function but #{typeof m.init}" unless \function is typeof m.init
    {context} = ad
    {name} = m
    if name? and \string is typeof name
      @name = name
      DBG "plugin[#{@name}]: name from module.exports.name"
    else if req isnt '.' and req isnt '..' and req is path.basename req
      @name = req
      DBG "plugin[#{@name}]: name from require(name)"
    else
      try
        {p, json} = LOAD_PACKAGE_JSON ad.environment.app_dir, filepath
        {name} = json
        @name = name if name? and \string is typeof name
        @package_json = json
        DBG "plugin[#{@name}]: name from package.json"
      catch error
        @package_json = null
        @name = req
        @name = path.basename path.dirname @name if @name.endsWith "index.js"
        @name = path.basename @name
        DBG "plugin[#{@name}]: name from dirname(module.id)"
    @callee = m
    @context = context
    return

  set-callee: (@callee=null) ->
    return @

  to-json: ->
    {req, filepath, name} = self = @
    return {req, filepath, name}

  attach: (environment, configs, helpers, context, done) ->
    {name, callee} = self = @
    return done! unless callee?
    {attach} = callee
    try
      self.dependencies = attach.apply context, [name, environment, configs, helpers]
    catch error
      return done error
    return done!



class AppContext
  (@app) ->
    {EventEmitter2} = eventemitter2
    @._server = new EventEmitter2 do
      wildcard: yes
      delimiter: \::
      newListener: no
      maxListeners: 20
    return

  set: (name, o) ->
    @[name] = o

  on: -> return @._server.on.apply @._server, arguments
  emit: -> return @._server.emit.apply @._server, arguments
  add-listener: -> return @._server.add-listener.apply @._server, arguments
  remove-listener: -> return @._server.remove-listener.apply @._server, arguments
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

  attach-plugins: (done) ->
    {environment, configs, context, plugins} = self = @
    helpers = {}
    f = (p, cb) -> return p.attach environment, configs[p.name], helpers, context, cb
    return async.eachSeries plugins, f, done




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
    {delegation} = self = @
    (attach-err) <- delegation.attach-plugins
    return done attach-err if attach-err?
    return self.start-internally done


module.exports = exports = {BaseApp, AppContext, AppPlugin}
