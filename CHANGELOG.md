# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed


## [0.4.1] - 2019-02-23

### Fixed
* Errors in panel box calculation with certain layouts.

### Added
* Documentation of element attributes is now generated based on element specs.


## [0.4.0] - 2019-02-22

### Added
* Applications based on the Elm Architecture.
  * App behaviour
  * Runtime
  * Runtime Supervisor
  * Components & Subscriptions
  * New examples

### Changed
* Views support labels as direct children.

### Removed
* Removed the experimental component support in favor of the new TEA-based apps.


## [0.3.0] - 2019-01-25

### Changed

* Element attributes are now validated based on the element's spec. Some
  attributes are optional, while others are required. It's not allowed to pass
  attributes that are not defined in the spec.
* The View DSL was extracted to `Ratatouille.View`. Imports like
  `import Ratatouille.Renderer.View` should be updated to `import Ratatouille.View`.
