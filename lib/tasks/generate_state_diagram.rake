desc 'Generate a graph for the application states'
task generate_state_diagram: :environment do
  require 'workflow/draw'
  Workflow::Draw::workflow_diagram(
    ApplicationStateChange,
    name: 'docs/states',
    orientation: 'portrait',
  )
end
