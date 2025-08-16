open Lwt.Syntax

let () =
  Lwt_main.run (
    let query = if Array.length Sys.argv > 1 then Sys.argv.(1) else "Berlin" in
    let+ result = Opencage.geocode query in
    match result with
    | Ok json -> print_endline (Yojson.Safe.pretty_to_string json)
    | Error (`Msg msg) -> prerr_endline msg
  )
