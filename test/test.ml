
open Lwt.Syntax

let test_successful_forward _ () =
  Unix.putenv "OPENCAGE_API_KEY" "6d0e711d72d74daeb2b0bfd2a5cdfdba";
  let* result = Opencage.geocode "Anything" in
  match result with
  | Ok json ->
      (* The OK test key returns as-if q=51.952659,7.632473; expect at least status.code=200 and total_results>=1 *)
      let open Yojson.Safe.Util in
      let code = member "status" json |> member "code" |> to_int in
      Alcotest.(check int) "status code" 200 code;
      let total = member "total_results" json |> to_int in
      Alcotest.(check bool) "some results" true (total >= 1);
      Lwt.return_unit
  | Error (`Msg msg) -> Alcotest.fail msg

let test_successful_reverse _ () =
  Unix.putenv "OPENCAGE_API_KEY" "6d0e711d72d74daeb2b0bfd2a5cdfdba";
  let* result = Opencage.reverse_geocode 52.5167 13.3833 in
  match result with
  | Ok json ->
      let open Yojson.Safe.Util in
      let code = member "status" json |> member "code" |> to_int in
      Alcotest.(check int) "status code" 200 code;
      let total = member "total_results" json |> to_int in
      Alcotest.(check bool) "at most one result" true (total >= 0 && total <= 1);
      Lwt.return_unit
  | Error (`Msg msg) -> Alcotest.fail msg

let test_no_results _ () =
  Unix.putenv "OPENCAGE_API_KEY" "6d0e711d72d74daeb2b0bfd2a5cdfdba";
  let* result = Opencage.geocode "NOWHERE-INTERESTING" in
  match result with
  | Ok json ->
      let open Yojson.Safe.Util in
      let total = member "total_results" json |> to_int in
      Alcotest.(check int) "total_results=0" 0 total;
    Lwt.return_unit
  | Error (`Msg msg) -> Alcotest.fail msg

let test_403_invalid_key _ () =
  Unix.putenv "OPENCAGE_API_KEY" "2e10e5e828262eb243ec0b54681d699a";
  let* result = Opencage.geocode "London" in
  match result with
  | Error (`Msg msg) ->
      (* Should stop and expose status.message *)
      Alcotest.(check bool) "contains message" true (String.length msg > 0);
      Lwt.return_unit
  | Ok _ -> Alcotest.fail "Expected error for disabled key"

let test_402_payment_required _ () =
  Unix.putenv "OPENCAGE_API_KEY" "4372eff77b8343cebfc843eb4da4ddc4";
  let* result = Opencage.geocode "London" in
  match result with
  | Error (`Msg msg) ->
      Alcotest.(check bool) "contains message" true (String.length msg > 0);
      Lwt.return_unit
  | Ok _ -> Alcotest.fail "Expected error for quota exceeded test key"

let () =
  let open Alcotest_lwt in
  Lwt_main.run (
    run "opencage-ocaml" [
      "geocoding", [
        test_case "Successful forward geocoding" `Quick test_successful_forward;
        test_case "Successful reverse geocoding" `Quick test_successful_reverse;
        test_case "No results" `Quick test_no_results;
        test_case "Invalid API key" `Quick test_403_invalid_key;
        test_case "Payment required" `Quick test_402_payment_required;
      ];
    ]
  )
