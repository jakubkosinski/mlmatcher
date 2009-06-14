(***********************************************************************)
(*                                                                     *)
(*                             MLMatcher                               *)
(*                                                                     *)
(*            Jakub Kosinski (jakub.kosinski@ghandal.net)              *)
(*                                                                     *)
(***********************************************************************)

(** Porter stemmer for english language.
   @author Martin Porter (ANSI C implementation)
   @author Jakub Kosinski (OCaml wrapper)
*)

external stem : string -> string = "porter"
(** [Stemmer.stem s] returns stem for [s]. *)

