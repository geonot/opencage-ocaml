open Lwt.Syntax

let () =
  Lwt_main.run (
    let+ result = Opencage.geocode "NOWHERE-INTERESTING" in
    match result with
    | Ok json ->
        let open Yojson.Safe.Util in
        let total = member "total_results" json |> to_int in
        if total = 0 then print_endline "No results found."
        else print_endline (Yojson.Safe.pretty_to_string json)
    | Error (`Msg msg) -> prerr_endline msg
  )
