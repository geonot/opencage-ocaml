# Changelog

All notable changes to this project will be documented in this file. This project adheres to [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) principles (dates in UTC).

## [1.0.1] - 2025-08-21
### Fixed
- Packaging: ensure `public_name` and opam package name are both `opencage`.
- Apply `dune subst` friendly version placeholder (`%%VERSION%%`) inside user-agent string.
- Scope test dependencies behind `:with-test` in `dune-project` so they are not required for end users.
- Correct syntax typo in `opencage.ml` (`type` vs `qtype`) that broke opam-repository CI.

### Added
- Public interface file `opencage.mli` documenting the API surface.
- This changelog.

## [1.0.0] - 2025-08-14
### Added
- Initial release of the OpenCage Geocoding client for OCaml (forward & reverse geocoding, optional params, structured error messages).

### Issues
- Rejected by opam-repository CI due to packaging / build issues fixed in 1.0.1.

---

[1.0.1]: https://github.com/geonot/opencage-ocaml/compare/1.0.0...1.0.1
