task :default => "compileopt"

desc "Compile using ocamlc"
task :compile do
  Rake::Task[:clib].invoke
  out = ENV['OUT'] || "Matcher.out"
  ["Index.mli", "Index.ml", "Main.ml"].each {|file| sh "ocamlc -c #{file}"}
  sh "ocamlc -o #{out} str.cma Stemmer.cma Index.cmo Main.cmo"
end

desc "Compile application using ocamlopt"
task :compileopt do |t|
  out = ENV['EXE'] || "Matcher"
  files = ["str.cmxa", "Stemmer.cmxa", "Index.ml", "Main.ml"]
  Rake::Task[:compile].invoke
  sh "ocamlopt -o #{out} #{files.join(" ")}"
end

desc "Compile C library"
task :clib do |t|
  sh "ocamlc -c Stemmer.mli"
  sh "ocamlc -c Stemmer.ml"
  sh "ocamlc -c Stemmer.c"
  sh "ocamlmklib -o stemmer Stemmer.cmo Stemmer.o"
  sh "ocamlc -a -o Stemmer.cma Stemmer.cmo -dllib dllstemmer.so"
  sh "ocamlopt -a -o Stemmer.cmxa Stemmer.ml Stemmer.mli Stemmer.o -cclib libstemmer.a"
end

desc "Cleanup directory and leave only source code"
task :clean do
  [:cmi,:cmo,:cmx,:o,:a,:cma].each do |ext|
    sh "rm -f *.#{ext}"
  end
end

desc "Run tests"
task :test do
end

