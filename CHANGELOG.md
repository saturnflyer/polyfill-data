# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

### Added

### Fixed

## 1.0.4

### Fixed

- loading from `Marshal.load` will create a frozen object
- `dup` will return a frozen object
- `define` cannot be used on Data subclasses
- `with` returns `self` when given no arguments

## 1.0.3

### Fixed

- `new` correctly raises ArugmentErrors with incorrect arguments on Data subclasses

## 1.0.2

### Fixed

- freeze after initializing
- `to_a` removed
- `deconstruct` fixed to return array in order of members as defined

## 1.0.1

### Added 

- `define` uses the first argument as a constant name if it is a string
- `[]` class method as an alias to `new`
- `to_s` method as an alias to `inspect`
- `deconstruct` method

### Fixed

- `initialize` only receives keyword arguments
- `inspect` includes comma separated list of members and values

## 1.0.0

### Added

- Initial implementation
