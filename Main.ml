open Index;;

let take n lst =
    let rec take_aux n lst acc =
        match n,lst with
        | 0,_ -> List.rev acc
        | n,[] -> List.rev acc
        | n,x::xs -> take_aux (n-1) xs (x::acc)
    in take_aux n lst [];;

let rec print_results lst n start () =
    match lst with
    | [] -> print_endline ("Searching done in " ^ (string_of_float(Sys.time() -. start)) ^ "s.")
    | x::xs -> print_results xs (n+1) start (print_endline (string_of_int(n) ^ ": " ^ (fst x) ^ " (" ^ string_of_float(snd x) ^ ")"));;

let print_prompt () = print_string "> ";;

(* Header info *)
let print_header () = print_string "
********************************************************************************
*                       Document matcher in OCaml                              *
*        (c) 2009 Jakub Kosinski (168225@student.pwr.wroc.pl)                  *
********************************************************************************
* Menu:                                                                        *
* quit        - quit program                                                   *
* menu        - prints menu                                                    *
* ndocs       - number of indexed docs                                         *
* index [DIR] - index documents in DIR                                         *
* find [N] [PATH] - return N most similar documents for document at PATH       *
* save [FILE] - save calculated index to file FILE                             *
* load [FILE] - load index from FILE                                           *
********************************************************************************
";;

let index = ref Index.create;;

let make_index directory =
    let startTime = Sys.time()
    in begin
        print_string "Indexing... ";
        flush stdout;
        index := from_directory directory;
        print_endline ("done in " ^ string_of_float((Sys.time()) -. startTime))
    end;;

let find n path =
    begin
        try print_results (take n (more_like_this path (!index))) 1 (Sys.time()) ();
        with _ -> print_endline "Wrong document path. Please try again.";
    end;;

let save path =
    Index.save_to_file (!index) path;;

let load path =
    try
        index := Index.load_from_file path
    with _ -> print_endline "Error during loading index from file. Please try again.";;

let ndocs () = print_endline ("Documents in index: " ^ string_of_int(documents (!index)));;

let process_option option =
    let params = Str.split (Str.regexp "\ +") option
    in match (List.hd params) with
        | "quit" -> exit 0
        | "ndocs" -> ndocs()
        | "menu" -> print_header()
        | "index" -> make_index (List.nth params 1)
        | "find" -> find (int_of_string(List.nth params 1)) (List.nth params 2)
        | "save" -> save (List.nth params 1)
        | "load" -> load (List.nth params 1)
        | _ -> failwith "Unrecognized option. Try again.";;

print_header();;

let option = ref "";;
begin
    while true do
        print_prompt();
        option := (read_line());
        try process_option (!option)
        with _ -> print_endline "Unrecognized option. Try again.";
    done;
end;;

