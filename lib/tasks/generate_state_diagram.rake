desc 'Generate a graph for the application states'
task generate_state_diagram: :environment do
  require 'workflow/draw'

  class ApplicationStateChangeWithoutProviderInvisibleStates
    def self.workflow_spec
      ApplicationStateChange.workflow_spec.tap do |spec|
        spec.states.reject! { |s| ApplicationStateChange::STATES_NOT_VISIBLE_TO_PROVIDER.include? s }
      end
    end
  end

  Workflow::Draw::workflow_diagram(
    ApplicationStateChange,
    name: 'docs/states',
    orientation: 'portrait',
  )

  Workflow::Draw::workflow_diagram(
    ApplicationStateChangeWithoutProviderInvisibleStates,
    name: 'public/api_docs/states',
    orientation: 'portrait',
  )
end
