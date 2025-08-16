open Lwt.Syntax

let () =
  Lwt_main.run (
    let command =
      if Array.length Sys.argv < 2 then (
        prerr_endline "Usage: opencage-ocaml-example <forward|reverse> [query|lat,lon]";
        exit 1)
      else Sys.argv.(1)
    in

    let run_geocode () =
      let query = if Array.length Sys.argv > 2 then Sys.argv.(2) else "" in
      if query = "" then (
        prerr_endline "Missing query for forward geocoding.";
        exit 1);
      let* result = Opencage.geocode query in
      match result with
      | Ok json ->
          print_endline (Yojson.Safe.pretty_to_string json);
          Lwt.return_unit
      | Error (`Msg msg) ->
          prerr_endline msg;
          Lwt.return_unit
    in

    let run_reverse_geocode () =
      let lat_lon_str = if Array.length Sys.argv > 2 then Sys.argv.(2) else "" in
      if lat_lon_str = "" then (
        prerr_endline "Missing lat,lon for reverse geocoding.";
        exit 1);
      try
        let lat, lon = Scanf.sscanf lat_lon_str "%f,%f" (fun lat lon -> (lat, lon)) in
        let* result = Opencage.reverse_geocode lat lon in
        match result with
        | Ok json ->
            print_endline (Yojson.Safe.pretty_to_string json);
            Lwt.return_unit
        | Error (`Msg msg) ->
            prerr_endline msg;
            Lwt.return_unit
      with Scanf.Scan_failure _ | End_of_file ->
        prerr_endline "Invalid lat,lon format. Expected: <lat>,<lon>";
        exit 1
    in

    match command with
    | "forward" -> run_geocode ()
    | "reverse" -> run_reverse_geocode ()
    | _ ->
        prerr_endline "Unknown command. Use 'forward' or 'reverse'.";
        exit 1
  )
      