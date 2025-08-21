open Lwt.Infix

let () =
  Lwt_main.run (
    let query = if Array.length Sys.argv > 1 then Sys.argv.(1) else "Berlin" in
    let params = [ ("language", "de"); ("countrycode", "de"); ("abbrv", "1") ] in
  Opencage.geocode ~params query >|= function
  | Ok json -> print_endline (Yojson.Safe.pretty_to_string json)
  | Error (`Msg msg) -> prerr_endline msg
  )
