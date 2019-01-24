# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

## [0.3.0] - 2019-01-25
### Added
- New examples and improved documentation.
### Changed
- Element attributes are now validated based on the element's spec. Some
  attributes are optional, while others are required. It's not allowed to pass
  attributes that are not defined in the spec.
- The View DSL was extracted to `Ratatouille.View`. Imports like
  `import Ratatouille.Renderer.View` should be updated to `import Ratatouille.View`.
