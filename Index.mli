type fvector
type tvector
type 'a t

(* Creates empty index *)
val create : tvector t

(* Returns number of indexed documents in given index *)
val documents : 'a t -> int

(* Calculates similarities between given document vectors *)
val similarity : tvector -> tvector -> float

(* Calculates similatiries between given documents' names in given index *)
val documents_similarity : string -> string -> tvector t -> float

(* Indexes files in given directory, returns weighted index *)
val from_directory : string -> tvector t

(* Returns list of indexed documents *)
val indexed_documents : tvector t -> string list

(* Returns list of tuples (document, similarity) for given document and weighted index *)
val more_like_this : string -> tvector t -> (string * float) list

(* Returns term vector for given file *)
val term_vector : string -> tvector t -> tvector

(* Saves calculated index to file *)
val save_to_file : tvector t -> string -> unit

(* Loads index from given file *)
val load_from_file : string -> tvector t

