#!/usr/bin/env lsc -cj
#
# Copyright (c) 2018 T2T Inc. All rights reserved
# https://www.t2t.io
# https://tic-tac-toe.io
# Taipei, Taiwan
#

# Known issue:
#   when executing the `package.ls` directly, there is always error
#   "/usr/bin/env: lsc -cj: No such file or directory", that is because `env`
#   doesn't allow space.
#
#   More details are discussed on StackOverflow:
#     http://stackoverflow.com/questions/3306518/cannot-pass-an-argument-to-python-with-usr-bin-env-python
#
#   The alternative solution is to add `envns` script to /usr/bin directory
#   to solve the _no space_ issue.
#
#   Or, you can simply type `lsc -cj package.ls` to generate `package.json`
#   quickly.
#

# package.json
#
name: \yapps-server

author:
  name: ['Yagamy']
  email: 'yagamy@t2t.io'

description: 'Server framework for TIC applications'

version: \0.1.0

repository:
  type: \git
  url: ''

main: \index.js

dependencies:
  livescript: \1.5.0
  colors: \*
  debug: \*
  yargs: \*
  minimist: \*
  rc: \*
  \js-yaml : \*
  mkdirp: \*
  async: \*
  lodash: \*
  eventemitter2: \*
  handlebars: \*

  bunyan : \*
  \bunyan-debug-stream : \*
  \bunyan-rotating-file-stream : \*

  express: \*
  \express-bunyan-logger : \*
  \body-parser : \*
  \socket.io :\*

devDependencies: {}

optionalDependencies: {}