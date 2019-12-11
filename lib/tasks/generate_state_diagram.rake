desc 'Generate a graph for the application states'
task generate_state_diagram: :environment do
  require 'workflow/draw'
  Workflow::Draw::workflow_diagram(
    ApplicationStateChange,
    name: 'docs/states',
    orientation: 'portrait',
  )
  FileUtils.mkdir_p(
    Rails.root.join('public', 'api_docs'),
  )
  FileUtils.cp(
    Rails.root.join('docs', 'states.png'),
    Rails.root.join('public', 'api_docs', 'states.png'),
  )
end
