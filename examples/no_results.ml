open Lwt.Infix

let () =
  Lwt_main.run (
  Opencage.geocode "NOWHERE-INTERESTING" >|= function
  | Ok json ->
    let open Yojson.Safe.Util in
    let total = member "total_results" json |> to_int in
    if total = 0 then print_endline "No results found."
    else print_endline (Yojson.Safe.pretty_to_string json)
  | Error (`Msg msg) -> prerr_endline msg
  )
