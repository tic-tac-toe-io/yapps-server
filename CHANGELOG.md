# Changelog

All notable changes to this project will be documented in this file. See [standard-version](https://github.com/conventional-changelog/standard-version) for commit guidelines.

### [0.2.4](https://github.com/tic-tac-toe-io/yapps-server/compare/v0.2.3...v0.2.4) (2021-07-16)


### Bug Fixes

* **util:** upgrade to js-yaml v4, and replace safeLoad() with load() ([9cc7367](https://github.com/tic-tac-toe-io/yapps-server/commit/9cc7367a194f675a1155f8b200e49f40a0e159a3))

### [0.2.3](https://github.com/tic-tac-toe-io/yapps-server/compare/v0.2.2...v0.2.3) (2021-07-16)


### Bug Fixes

* **npm:** lock mkdirp to 0.5.5 for backward compatibility, and use package.json as single source of package manifest to phase out package.ls ([925ac66](https://github.com/tic-tac-toe-io/yapps-server/commit/925ac6601df07b7a90d3a1aac171f4664c5cd878))

### [0.2.2](https://github.com/tic-tac-toe-io/yapps-server/compare/v0.2.1...v0.2.2) (2020-04-26)


### Bug Fixes

* **npm:** update node module dependencies to latest ([ae3abf0](https://github.com/tic-tac-toe-io/yapps-server/commit/ae3abf06e9c44ac4298ebaaa18ea9f299f1212d6))

### 0.2.1 (2020-04-26)


### Features

* **web:** apply socket_io options from the web section of configuration yaml file ([114b171](https://github.com/tic-tac-toe-io/yapps-server/commit/114b1714a5167333d9c6aeef8229fde95ce019cc))

## [0.2.0] - 2019-06-12
### Changed
- Breaking: refactorying codes to support CLI commands: `start` and `cfg`

## [0.1.9] - 2019-06-10
### Fixed
- Workaround: Load `@tic-tac-toe/browserify-livescript-middleware` before requiring `livescript` in order to make sure `livescript` is already loaded ()

### Removed
- Remove `livescript` from package.json and package.ls


## [0.1.8] - 2019-06-09
## Added
- Add "livescript: github:ischenkodv/LiveScript" to package.json in order to fix startup failure due to missing `livescript` in `node_modules` directory

## [0.1.7] - 2019-06-05
### Changed
- Upgrade `browserify-livescript-middleware` to v1.3.0

## [0.1.6] - 2019-06-04
### Changed
- Replace `@tic-tac-toe/livescript-middleware` with `@tic-tac-toe/browserify-livescript-middleware`

## [0.1.5] - 2019-05-28
### Added
- Support views/html with PUG template engine
- Support views/javascript with livescript-middleware
- Suppoer views/css with static resources

## [0.1.4] - 2019-05-23
### Added
- Generate `service_instance_id` in the environment context
- Support external authenticator for socket.io namespaces

### Fixed
- Fix template message of `missing_field` web error

## [0.1.3] - 2019-03-07
### Added
- Apply CHANGELOG to automatically generate `version` in package.json when publishing to npm registry
- Only publish `/src/*` files to npm registry

## [0.1.0] - 2019-01-16
### Changed
- Initial version
