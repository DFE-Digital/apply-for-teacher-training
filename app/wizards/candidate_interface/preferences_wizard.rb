class CandidateInterface::PreferencesWizard
  include DfE::Wizard

  attr_accessor :current_application

  delegate :opt_in?,
           :training_locations_anywhere?,
           :training_locations_specific?,
           :only_salaried_courses_and_anywhere?,
           :applied_only_to_salaried_courses?,
           :training_locations,
           :funding_type,
           to: :state_store

  def steps_processor
    DfE::Wizard::StepsProcessor::Graph.draw(self, predicate_caller: state_store) do |graph|
      graph.add_node :opt_in, CandidateInterface::Steps::PreferencesWizard::OptIn
      graph.add_node :training_locations, CandidateInterface::Steps::PreferencesWizard::TrainingLocations
      graph.add_node :location_preferences, CandidateInterface::Steps::PreferencesWizard::LocationPreferences
      graph.add_node :funding_preferences, CandidateInterface::Steps::PreferencesWizard::FundingPreferences
      graph.add_node :publish, CandidateInterface::Steps::PreferencesWizard::Publish
      graph.add_node :opt_out, CandidateInterface::Steps::PreferencesWizard::Confirmation
      graph.add_node :opt_out, CandidateInterface::Steps::PreferencesWizard::OptOut

      graph.root :opt_in

      graph.add_conditional_edge(
        from: :opt_in,
        when: :opt_in?,
        then: :training_locations,
        else: :opt_out,
      )

      graph.add_multiple_conditional_edges(
        from: :training_locations,
        branches: [
          { when: :only_salaried_courses_and_anywhere?, then: :funding_preferences },
          { when: :training_locations_anywhere?, then: :publish },
          { when: :training_locations_specific?, then: :location_preferences },
        ],
        default: :publish,
      )

      graph.add_edge from: :publish, to: :confirmation
    end
  end

  def route_strategy
    DfE::Wizard::RouteStrategy::DynamicRoutes.new(
      state_store:,
      path_builder: lambda { |step_id, _state_store, helpers, options|
        case step_id
        when :opt_out
          helpers.candidate_interface_invites_path
        when :confirmation
          helpers.show_candidate_interface_pool_opt_ins_path
        else
          helpers.candidate_interface_new_preferences_path(
            step: step_id,
            **options,
          )
        end
      },
    )
  end
end
