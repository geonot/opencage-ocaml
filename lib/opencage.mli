type 'a response = ('a, [ `Msg of string ]) result

val geocode : ?params:(string * string) list -> string -> Yojson.Safe.t response Lwt.t
(** [geocode ~params query]
    Forward geocodes the given query string.
    @param params A list of optional parameters to pass to the API.
    @param query The query to geocode.
    @return A Lwt promise that resolves to a result containing either the JSON response or an error message. *)

val reverse_geocode : ?params:(string * string) list -> float -> float -> Yojson.Safe.t response Lwt.t
(** [reverse_geocode ~params lat lon]
    Reverse geocodes the given latitude and longitude.
    @param params A list of optional parameters to pass to the API.
    @param lat The latitude.
    @param lon The longitude.
    @return A Lwt promise that resolves to a result containing either the JSON response or an error message. *)