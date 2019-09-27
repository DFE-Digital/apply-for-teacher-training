desc "Lint all *.erb* files in app/views using erblint"
task :lint_erb do
  sh("erblint app/views")
end
