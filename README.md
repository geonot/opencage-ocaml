# OpenCage SDK for OCaml

[![Build Status](https://github.com/geonot/opencage-ocaml/actions/workflows/ci.yml/badge.svg)](https://github.com/geonot/opencage-ocaml/actions/workflows/ci.yml)

OCaml bindings for the [OpenCage Geocoding API](https://opencagedata.com).

This library provides a simple and easy-to-use interface for the OpenCage API, allowing you to perform both forward and reverse geocoding.

## Installation

The recommended way to install `opencage` is via the [opam](https://opam.ocaml.org) package manager:

```bash
opam install opencage
```

## Prerequisites

Before using this library, you need to have the following installed:

* [OCaml](https://ocaml.org/docs/install.html) (>= 4.08.0)
* [dune](https://dune.build)
* [opam](https://opam.ocaml.org/doc/Install.html)

## API Key

To use the OpenCage API, you need to get an API key from the [OpenCage website](https://opencagedata.com/users/sign_up). Once you have your key, you need to set it as an environment variable:

```bash
export OPENCAGE_API_KEY="your-api-key"
```

This library sends a unique User-Agent header of the form `ocaml-opencage/<version>` with each request to help the OpenCage team diagnose issues.

## Usage

Here are some examples of how to use the library:

### Forward Geocoding

```ocaml
open Lwt.Syntax

let () =
  Lwt_main.run (
    let+ result = Opencage.geocode "82 Clerkenwell Road, London" in
    match result with
    | Ok json -> print_endline (Yojson.Safe.pretty_to_string json)
    | Error (`Msg msg) -> prerr_endline msg
  )
```

### Reverse Geocoding

```ocaml
open Lwt.Syntax

let () =
  Lwt_main.run (
    let+ result = Opencage.reverse_geocode 51.5235427 (-0.1099724) in
    match result with
    | Ok json -> print_endline (Yojson.Safe.pretty_to_string json)
    | Error (`Msg msg) -> prerr_endline msg
  )
```

### Handling No Results

The API may return a valid response with no results. You can handle this case as follows:

```ocaml
open Lwt.Syntax

let () =
  Lwt_main.run (
    let+ result = Opencage.geocode "NOWHERE-INTERESTING" in
    match result with
    | Ok json ->
        let open Yojson.Safe.Util in
        let total = member "total_results" json |> to_int in
        if total = 0 then
          print_endline "No results found."
        else
          print_endline (Yojson.Safe.pretty_to_string json)
    | Error (`Msg msg) -> prerr_endline msg
  )
```

### Using Optional Parameters

You can pass optional parameters to the API using the `~params` argument:

```ocaml
open Lwt.Syntax

let () =
  Lwt_main.run (
    let params = [ ("language", "de"); ("countrycode", "de"); ("abbrv", "1") ] in
    let+ result = Opencage.geocode ~params "Berlin" in
    match result with
    | Ok json -> print_endline (Yojson.Safe.pretty_to_string json)
    | Error (`Msg msg) -> prerr_endline msg
  )
```

## Best Practices

For best practices, please refer to the [OpenCage API best practices](https://opencagedata.com/api#bestpractices) and the guide on [formatting forward geocoding queries](https://opencagedata.com/guides/how-to-format-your-geocoding-query).

Testing notes:

- OpenCage provides [testing API keys](https://opencagedata.com/api#testingkeys) that deterministically return specific responses. Our test suite uses these keys, and you can also use them for local testing.
- To simulate a valid request with no results, use the query `NOWHERE-INTERESTING` which will return `200` with `total_results = 0`.
- By default, the published test executable skips real network calls (for opam-repository CI). Set `OPENCAGE_RUN_NETWORK_TESTS=1` to run the live HTTP tests locally:

```bash
OPENCAGE_RUN_NETWORK_TESTS=1 dune runtest
```

## Examples

Quick ways to try the library (using the provided example executables):

```bash
# Set the API key (use a real key, or the OpenCage 200-OK test key for demos)
export OPENCAGE_API_KEY=6d0e711d72d74daeb2b0bfd2a5cdfdba

# Forward geocoding
dune exec examples/forward.exe -- "Berlin"

# Reverse geocoding
dune exec examples/reverse.exe -- "52.5167,13.3833"

# Valid request with no results
dune exec examples/no_results.exe --

# Forward geocoding with optional parameters
dune exec examples/params.exe -- "Berlin"
```

After installation, you can also run the public names:

```bash
oc-opencage-forward "Berlin"
oc-opencage-reverse "52.5167,13.3833"
oc-opencage-no-results
oc-opencage-params "Berlin"
```

## License

This library is licensed under the MIT license. See the [LICENSE](LICENSE) file for more details.
