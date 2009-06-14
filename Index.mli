(***********************************************************************)
(*                                                                     *)
(*                             MLMatcher                               *)
(*                                                                     *)
(*            Jakub Kosinski (jakub.kosinski@ghandal.net)              *)
(*                                                                     *)
(***********************************************************************)

(** Index structure and functions.

   Index stores terms' stems from documents and calculates similarities
   for given documents. Stems are calculated using Porter {!Stemmer}.
   @author Jakub Kosinski
*)

type fvector
(** The type of word-frequency vector. *)

type tvector
(** The type of term vector. Stores information about term
   and its tf-idf weight. *)

type 'a t
(** The type of index with String as keys and values from
   type ['a] which may be either word-frequency vector {!fvector}
   or term vector {!tvector}. *)

(** Index operations *)

val create : tvector t
(** [Index.create] creates a new, empty index. *)

val documents : 'a t -> int
(** [Index.documents i] returns the number of indexed documents
   in [i]. *)

val from_directory : string -> tvector t
(** [Index.from_directory dir] creates index from all files from
   [dir], including all files in [dir] subdirectories. *)

val indexed_documents : tvector t -> string list
(** [Index.indexed_documents i] returns list of all documents
   indexed in [i]. *)

val save_to_file : tvector t -> string -> unit
(** [Index.save_to_file i name] saves index [i] to file named [name]. *)

val load_from_file : string -> tvector t
(** [Index.load_from_file file] returns index loaded from file named [name]. *)

(** Documents similarity operations *)

val similarity : tvector -> tvector -> float
(** [Index.similarity v1 v2] calculates similarity between
   term vectors [v1] and [v2]. *)

val documents_similarity : string -> string -> tvector t -> float
(** [Index.documents_similarity doc1 doc2 index] calculates similarities
   between documents [doc1] and [doc2] using index [index]. *)

val more_like_this : string -> tvector t -> (string * float) list
(** [Index.more_like_this doc i] returns list of tuples (document, similarity)
   for document [doc] and index with term vectors ({!tvector}) [i] sorted
   descending by similarity to [doc]. *)

val term_vector : string -> tvector t -> tvector
(** [Index.term_vector doc i] returns {!tvector} for [doc] from {!tvector}
   index [i]. *)

