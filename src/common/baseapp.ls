#
# Copyright (c) 2018 T2T Inc. All rights reserved
# https://www.t2t.io
# https://tic-tac-toe.io
# Taipei, Taiwan
#
require! <[handlebars]>
{services} = global.yac
{DBG, ERR, WARN, INFO} = services.get_module_logger __filename
{MERGE_JSON_TEMPLATE} = require \../helpers/utils


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
    return

  init-internally: (environment, configs, done) ->
    return done!

  init: (done) ->
    {environment, templated_configs} = self = @
    try
      self.configs = configs = MERGE_JSON_TEMPLATE templated_configs, environment
    catch error
      return done error
    return @.init-internally environment, configs, done

  start: (done) ->
    return done!


module.exports = exports = BaseApp
