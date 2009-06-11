module StringMap = Map.Make(String)

exception DocumentNotFound of string

type key = StringMap.key
type fvector = (String.t * int) list
type tvector = (String.t * float) list
type 'a t = 'a StringMap.t

(* Creates empty index *)
let create = StringMap.empty;;

(* Removes duplicates from given list. Result is not sorted *)
let unique lst =
    let tbl = Hashtbl.create (List.length lst)
    in
        List.iter (fun i -> Hashtbl.replace tbl i ()) lst;
        Hashtbl.fold (fun key data accu -> key :: accu) tbl []

(* Converts list of words to list of tuples (word, frequency) *)
let compact array =
    let rec add_word word array =
        match array with
        | [] -> [(word, 1)]
        | (x,f)::xs -> if x = word
                       then (x, f+1)::xs
                       else (x,f)::(add_word word xs)
    and process array result =
        match array with
        | [] -> List.sort (fun x y -> (String.compare (fst x) (fst y))) result
        | x::xs -> process xs (add_word x result)
    in process array []

(* Creates list of words from given document *)
let document_to_word_list path =
    let rec file = open_in path
    and process file result =
        try
            process file ((Str.split (Str.regexp "[ \n\t\r]+") (Str.global_substitute (Str.regexp "[^ \n\t\ra-zA-Z0-9_]") (fun s -> "") (input_line file)))::result)
        with
        | e -> ((close_in file), (List.map (fun s -> String.lowercase s) (List.rev (List.flatten (List.map (fun l -> List.rev l) result)))))
    in snd (process file [])

(* Adds given document to given index represented by StringMap *)
let index_document doc index = StringMap.add doc (compact (document_to_word_list doc)) index

(* Returns number of indexed documents in given index *)
let documents index = StringMap.fold (fun k v acc -> acc + 1) index 0

(* Calculates similarities for given document vectors *)
let similarity doc1 doc2 =
    let rec calculate_similarity l1 l2 acc =
        match l1,l2 with
        | [],_ -> acc
        | _,[] -> acc
        | (x::xs),(y::ys) -> if (fst x) = (fst y) then calculate_similarity xs ys (acc +. (snd x *. snd y))
                             else if String.compare (fst x) (fst y) < 0
                             then calculate_similarity xs (y::ys) acc
                             else calculate_similarity (x::xs) ys acc
     in calculate_similarity doc1 doc2 0.

let documents_similarity doc1 doc2 index =
    if StringMap.mem doc1 index = true && StringMap.mem doc2 index
    then similarity (StringMap.find doc1 index) (StringMap.find doc2 index)
    else raise (DocumentNotFound "Document not found in index")

(* Calculates length of vector *)
let length doc = sqrt (List.fold_left (fun acc e -> acc +. (e *. e)) 0. (List.map (fun x -> snd x) doc))

(* Normalizes the vector *)
let normalize doc =
    let l = length doc
    in List.map (fun (w,f) -> (w, f /. l)) doc

(* Calculates tf-idf weight for given document, BOW and n (number of indexed documents) with global frequencies; returns list of tuples (word, tfidf) without common words (word is common if its tfidf is less or equal to 0) *)
(* w_{d,t} = tf_{d,t} \cdot \log{\frac{N}{f_{t}}} *)
let tfidf doc bow index = List.filter (fun (word, tfidf) -> tfidf > 0.) ((List.map (fun (word, freq) -> (word, float_of_int(freq) *. log (float_of_int((documents index)) /. float_of_int(StringMap.find word bow)))) doc))

(* Returns index with (word, tfidf) tuples instead of (word, frequency) *)
let weight_index index bow = StringMap.map (fun v -> normalize(tfidf v bow index)) index

(* Returns list of all files from given directory and subdirectories *)
let rec glob dir =
    let (dirs,files) = List.partition (fun file -> Sys.is_directory file) (List.map (fun f -> dir ^ "/" ^ f) (Array.to_list (Sys.readdir dir)))
    in List.map (fun f -> Str.replace_first (Str.regexp "^\\./") "" f) ((List.flatten (List.map (fun d -> glob d) dirs)) @ (files));;

(* Indexes files in given directory (but not with subdirectories), returns index *)
let index_directory dir =
    let rec process_files lst index =
        match lst with
        | [] -> index
        | x::xs -> process_files xs (index_document x index)
    in process_files (glob dir) StringMap.empty

(* Returns list of token from given vector *)
let tokens_from_tvector tvector =
    unique (List.map (fun pair -> fst pair) tvector)

(* Adds all given tuples (word, frequency) to BOW - StringMap with words as keys and # of documents with given term as values *)
let add_words_to_bow words bow =
    let add bow word =
        if StringMap.mem word bow
        then StringMap.add word ((StringMap.find word bow) + 1) (StringMap.remove word bow)
        else StringMap.add word 1 bow
    in
    List.fold_left add bow words

(* Creates BOW from index *)
let create_bow_from_index index = StringMap.fold (fun k v acc -> (add_words_to_bow (tokens_from_tvector v) acc)) index StringMap.empty

(* Indexes files in given directory, returns weighted index *)
let from_directory dir =
    let index = index_directory dir
    in weight_index index (create_bow_from_index index);;

(* Returns list of indexed documents *)
let indexed_documents index = List.rev (StringMap.fold (fun k v acc -> k::acc) index []);;

(* Returns list of tuples (document, similarity) for given document and weighted index *)
let more_like_this doc index =
    let v = StringMap.find doc index
    in List.sort (fun x y -> -1 * compare (snd x) (snd y)) (StringMap.fold (fun key value list -> if value=v then list else (key, (similarity v value))::list) index [])

let term_vector doc index = StringMap.find doc index;;

(* Saves index to given file *)
let save_to_file index file =
    let out_channel = open_out_bin file
    in begin
        Marshal.to_channel out_channel index [];
        close_out out_channel
    end;;

(* Loads index from given file *)
let load_from_file file =
    let in_channel = open_in_bin file
    and result = ref (StringMap.empty)
    in begin
        result := Marshal.from_channel in_channel;
        close_in in_channel;
        (!result)
    end;;

