# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.5.1] - 2020-04-27

### Changed

* Added support for extended colors

## [0.5.1] - 2020-03-24

### Changed
* Updated build dependencies.


## [0.5.0] - 2019-04-28

### Fixed
* Possible rendering error with multi-byte UTF-8 characters.

### Added
* New `viewport` element for offsetting the render origin of child
  content (e.g., to implement scrolling)
* New `canvas` and `canvas_cell` elements for drawing arbitrary shapes
  (see snake example).
* Support for rendering multi-line content (with automatic line
  wrapping) given to the `label` element.
* Support for styling tree node content.
* Support for styling panel title content (thanks to @iboard) and
  configuring panel's padding.
* Support for passing colors and text attributes directly as
  atoms, so the integer constants no longer need to be looked up.
* Improved documentation of element hierarchy restrictions (thanks to
  @trescenzi)


## [0.4.2] - 2019-03-03

### Fixed
* Possible crash in the termbox NIFs when polling for events (updates ex_termbox
  to 1.0.0).


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
