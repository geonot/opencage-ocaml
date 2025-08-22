(lang dune 3.0)
(name opencage)
(generate_opam_files true)
(source (github geonot/opencage-ocaml))
(authors "Rome Stone <fractalattice@gmail.com>")
(maintainers "Rome Stone <fractalattice@gmail.com>")
(license MIT)
(documentation https://geonot.github.io/opencage-ocaml)

(package
 (name opencage)
 (synopsis "OCaml bindings for the OpenCage Geocoding API")
 (description "A complete OCaml library for the OpenCage Geocoding API.")
 (depends
  (ocaml (>= 4.08.0))
  cohttp-lwt-unix
    (yojson (>= 2.0.0))
  lwt
  conduit-lwt-unix
  tls
  tls-lwt
  (alcotest :with-test)
  (alcotest-lwt :with-test))
 (tags ("geocoding" "opencage" "api" "bindings" "lwt"))
)