(lang dune 3.17)
(name opencage-ocaml)
(generate_opam_files true)
(source (github geonot/opencage-ocaml))
(authors "Rome Stone <fractalattice@gmail.com>")
(maintainers "Rome Stone <fractalattice@gmail.com>")
(license MIT)
(documentation https://geonot.github.io/opencage-ocaml)

(package
 (name opencage-ocaml)
 (synopsis "OCaml bindings for the OpenCage Geocoding API")
 (description "A complete OCaml library for the OpenCage Geocoding API.")
(depends ocaml
         cohttp-lwt-unix
         yojson
         lwt
         conduit-lwt-unix
         tls
         tls-lwt
         lwt_ssl
         alcotest
         alcotest-lwt
         lwt_ppx)
 (tags ("geocoding" "opencage" "api" "bindings" "lwt"))
)