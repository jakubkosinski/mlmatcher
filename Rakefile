task :default => "compileopt"

desc "Compile using ocamlc"
task :compile do
  out = ENV['OUT'] || "Matcher.out"
  ["Index.mli", "Index.ml", "Main.ml"].each {|file| sh "ocamlc -c #{file}"}
  sh "ocamlc -o #{out} str.cma Index.cmo Main.cmo"
end

desc "Compile application using ocamlopt"
task :compileopt do |t|
  out = ENV['EXE'] || "Matcher"
  files = ["str.cmxa", "Index.ml", "Main.ml"]
  Rake::Task[:compile].invoke
  sh "ocamlopt -o #{out} #{files.join(" ")}"
end

desc "Cleanup directory"
task :clean do
  [:cmi,:cmo,:cmx,:o].each do |ext|
    sh "rm *.#{ext}"
  end
end

desc "Run tests"
task :test do
end

