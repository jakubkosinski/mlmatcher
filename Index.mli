type fvector
type tvector
type 'a t

(* Adds given document to given index represented by StringMap *)
val index_document : string -> fvector t -> fvector t

(* Returns number of indexed documents in given index *)
val documents : 'a t -> int

(* Adds all given tuples (word, frequency) to BOW - StringMap with words as strings and global frequencies as values *)
val add_words_to_bow : fvector -> int t -> int t

(* Calculates similarities between given document vectors *)
val similarity : tvector -> tvector -> float

(* Calculates similatiries between given documents' names in given index *)
val documents_similarity : string -> string -> tvector t -> float

(* Returns index with (word, tfidf) tuples instead of (word, frequency) *)
val weight_index : fvector t -> int t -> tvector t

(* Indexes files in given directory, returns index *)
val index_directory : string -> fvector t

(* Indexes files in given directory, returns weighted index *)
val windex_directory : string -> tvector t

(* Returns list of indexed documents *)
val indexed_documents : tvector t -> string list

(* Creates BOW from index *)
val create_bow_from_index : fvector t -> int t

(* Returns list of tuples (document, similarity) for given document and weighted index *)
val more_like_this : string -> tvector t -> (string * float) list

(* Returns term vector for given file *)
val term_vector : string -> tvector t -> tvector

(* Saves calculated index to file *)
val save_to_file : tvector t -> string -> unit

(* Loads index from given file *)
val load_from_file : string -> tvector t

