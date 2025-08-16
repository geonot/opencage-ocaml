open Lwt.Syntax

let () =
  Lwt_main.run (
    let usage () =
      prerr_endline "Usage: reverse <lat,lon>"; exit 1
    in
    if Array.length Sys.argv < 2 then usage ();
    let lat, lon =
      try Scanf.sscanf Sys.argv.(1) "%f,%f" (fun lat lon -> (lat, lon))
      with _ -> usage ()
    in
    let+ result = Opencage.reverse_geocode lat lon in
    match result with
    | Ok json -> print_endline (Yojson.Safe.pretty_to_string json)
    | Error (`Msg msg) -> prerr_endline msg
  )
