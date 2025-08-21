
(* Network tests are disabled by default for opam-repository CI which forbids
   outbound network / may have restricted DNS. Set OPENCAGE_RUN_NETWORK_TESTS=1
   to enable the real HTTP tests locally. *)

open Lwt.Infix

let network_enabled = Sys.getenv_opt "OPENCAGE_RUN_NETWORK_TESTS" = Some "1"

(* Helpers for actual network tests (only built/run when enabled) *)
let net_tests () =
  let test_successful_forward _ () =
    Unix.putenv "OPENCAGE_API_KEY" "6d0e711d72d74daeb2b0bfd2a5cdfdba";
  Opencage.geocode "Anything" >>= fun result ->
    match result with
    | Ok json ->
        let open Yojson.Safe.Util in
        let code = member "status" json |> member "code" |> to_int in
        Alcotest.(check int) "status code" 200 code;
        let total = member "total_results" json |> to_int in
        Alcotest.(check bool) "some results" true (total >= 1);
        Lwt.return_unit
    | Error (`Msg msg) -> Alcotest.fail msg
  in
  let test_successful_reverse _ () =
    Unix.putenv "OPENCAGE_API_KEY" "6d0e711d72d74daeb2b0bfd2a5cdfdba";
  Opencage.reverse_geocode 52.5167 13.3833 >>= fun result ->
    match result with
    | Ok json ->
        let open Yojson.Safe.Util in
        let code = member "status" json |> member "code" |> to_int in
        Alcotest.(check int) "status code" 200 code;
        let total = member "total_results" json |> to_int in
        Alcotest.(check bool) "at most one result" true (total >= 0 && total <= 1);
        Lwt.return_unit
    | Error (`Msg msg) -> Alcotest.fail msg
  in
  let test_no_results _ () =
    Unix.putenv "OPENCAGE_API_KEY" "6d0e711d72d74daeb2b0bfd2a5cdfdba";
  Opencage.geocode "NOWHERE-INTERESTING" >>= fun result ->
    match result with
    | Ok json ->
        let open Yojson.Safe.Util in
        let total = member "total_results" json |> to_int in
        Alcotest.(check int) "total_results=0" 0 total;
        Lwt.return_unit
    | Error (`Msg msg) -> Alcotest.fail msg
  in
  let test_403_invalid_key _ () =
    Unix.putenv "OPENCAGE_API_KEY" "2e10e5e828262eb243ec0b54681d699a";
  Opencage.geocode "London" >>= fun result ->
    match result with
    | Error (`Msg msg) ->
        Alcotest.(check bool) "contains message" true (String.length msg > 0);
        Lwt.return_unit
    | Ok _ -> Alcotest.fail "Expected error for disabled key"
  in
  let test_402_payment_required _ () =
    Unix.putenv "OPENCAGE_API_KEY" "4372eff77b8343cebfc843eb4da4ddc4";
  Opencage.geocode "London" >>= fun result ->
    match result with
    | Error (`Msg msg) ->
        Alcotest.(check bool) "contains message" true (String.length msg > 0);
        Lwt.return_unit
    | Ok _ -> Alcotest.fail "Expected error for quota exceeded test key"
  in
  [
    Alcotest_lwt.test_case "Successful forward geocoding" `Quick test_successful_forward;
    Alcotest_lwt.test_case "Successful reverse geocoding" `Quick test_successful_reverse;
    Alcotest_lwt.test_case "No results" `Quick test_no_results;
    Alcotest_lwt.test_case "Invalid API key" `Quick test_403_invalid_key;
    Alcotest_lwt.test_case "Payment required" `Quick test_402_payment_required;
  ]

let offline_tests () =
  let triv _ () = Lwt.return (Alcotest.(check bool) "offline placeholder" true true) in
  [ Alcotest_lwt.test_case "Offline placeholder" `Quick triv ]

let () =
  let open Alcotest_lwt in
  let group_name, tests = if network_enabled then ("geocoding", net_tests ()) else ("offline", offline_tests ()) in
  Lwt_main.run (run "opencage" [ (group_name, tests) ])
