type 'a response = ('a, [ `Msg of string ]) result
open Lwt.Infix
open Cohttp_lwt_unix

let base_uri = Uri.of_string "https://api.opencagedata.com/geocode/v1/json"
(* The version string is substituted during release by [dune subst]. *)
let version = "%%VERSION%%"

let get_api_key () :
    (string, [> `Msg of string ]) result Lwt.t = 
  try Lwt.return (Ok (Sys.getenv "OPENCAGE_API_KEY"))
  with Not_found -> Lwt.return (Error (`Msg "OPENCAGE_API_KEY environment variable not set"))

let make_uri api_key params =
  let all_params = ("key", api_key) :: params in
  Uri.add_query_params base_uri (List.map (fun (k, v) -> (k, [v])) all_params)

let make_headers () =
  let user_agent = Printf.sprintf "ocaml-opencage/%s" version in
  Cohttp.Header.init_with "User-Agent" user_agent

let parse_response body :
    (Yojson.Safe.t, [> `Msg of string ]) result Lwt.t = 
  try
    let json = Yojson.Safe.from_string body in
    Lwt.return (Ok json)
  with Yojson.Json_error msg ->
    Lwt.return (Error (`Msg ("Failed to parse JSON: " ^ msg)))

let handle_response (resp, body) :
    (Yojson.Safe.t, [> `Msg of string ]) result Lwt.t = 
  let status = Cohttp.Response.status resp in
  let code = Cohttp.Code.code_of_status status in
  Cohttp_lwt.Body.to_string body >>= fun body_str ->
  if Cohttp.Code.is_success code then
    parse_response body_str
  else
    let message =
      (* Try to read status.message from JSON error body; fall back to HTTP status string or raw body *)
      try
        let json = Yojson.Safe.from_string body_str in
        Yojson.Safe.Util.(member "status" json |> member "message" |> to_string)
      with _ ->
        let status_str = Cohttp.Code.string_of_status status in
        if String.length body_str > 0 then status_str ^ ": " ^ body_str else status_str
    in
    match code with
    | 402 | 403 -> Lwt.return (Error (`Msg (Printf.sprintf "Request failed: %s" message)))
    | _ -> Lwt.return (Error (`Msg (Printf.sprintf "HTTP request failed: %s" message)))

let make_request uri :
    (Yojson.Safe.t, [> `Msg of string ]) result Lwt.t = 
  let headers = make_headers () in
  Client.get ~headers uri >>= handle_response

let geocode ?(params = []) query :
    (Yojson.Safe.t, [> `Msg of string ]) result Lwt.t = 
  get_api_key () >>= function
  | Error e -> Lwt.return (Error e)
  | Ok api_key ->
    let uri = make_uri api_key (("q", query) :: params) in
    make_request uri

let reverse_geocode ?(params = []) lat lon :
    (Yojson.Safe.t, [> `Msg of string ]) result Lwt.t = 
  get_api_key () >>= function
  | Error e -> Lwt.return (Error e)
  | Ok api_key ->
    let query = Printf.sprintf "%f,%f" lat lon in
    let uri = make_uri api_key (("q", query) :: params) in
    make_request uri
