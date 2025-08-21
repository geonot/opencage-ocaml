# Changelog

All notable changes to this project will be documented in this file. This project adheres to [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) principles (dates in UTC).

## [1.0.3] - 2025-08-21
### Fixed
- Add minimum `yojson >= 2.0.0` constraint to ensure `Yojson.Safe.t` type constructor is present under older compiler / lower-bound resolution. (opam CI 4.08 lower-bounds previously downgraded yojson to 1.5.0 causing build failure.)

## [1.0.2] - 2025-08-21
### Changed
- Gate network-dependent tests behind `OPENCAGE_RUN_NETWORK_TESTS=1` (default disabled) so opam-repository CI (which disallows external network/DNS in some sandboxes or older compilers) can build the package successfully. Provides a fast offline placeholder test when disabled.

### Removed
- Drop `lwt_ssl` dependency (TLS handled by `tls` / `conduit*` stack) to simplify dependency graph and future Windows support.

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

[1.0.2]: https://github.com/geonot/opencage-ocaml/compare/1.0.1...1.0.2
[1.0.3]: https://github.com/geonot/opencage-ocaml/compare/1.0.2...1.0.3
[1.0.1]: https://github.com/geonot/opencage-ocaml/compare/1.0.0...1.0.1
