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
           :location_name,
           :location_preferences,
           :dynamic_location_preferences?,
           :any_notifications?,
           to: :state_store

  def steps_processor
    DfE::Wizard::StepsProcessor::Graph.draw(self, predicate_caller: state_store) do |graph|
      graph.add_node :opt_in, CandidateInterface::Steps::PreferencesWizard::OptIn
      graph.add_node :training_locations, CandidateInterface::Steps::PreferencesWizard::TrainingLocations
      graph.add_node :location_preference_list, CandidateInterface::Steps::PreferencesWizard::LocationPreferenceList

      graph.add_node :add_location_preference, CandidateInterface::Steps::PreferencesWizard::AddLocationPreference
      graph.add_node :remove_location_preference, CandidateInterface::Steps::PreferencesWizard::RemoveLocationPreference

      graph.add_node :dynamic_location_preferences, CandidateInterface::Steps::PreferencesWizard::DynamicLocationPreferences
      graph.add_node :funding_preference, CandidateInterface::Steps::PreferencesWizard::FundingPreference
      graph.add_node :publish, CandidateInterface::Steps::PreferencesWizard::Publish
      graph.add_node :confirmation, CandidateInterface::Steps::PreferencesWizard::Confirmation
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
          { when: :only_salaried_courses_and_anywhere?, then: :funding_preference },
          { when: :training_locations_anywhere?, then: :publish },
          { when: :training_locations_specific?, then: :location_preference_list },
        ],
        default: :publish,
      )

      graph.add_edge from: :add_location_preference, to: :location_preference_list
      graph.add_edge from: :remove_location_preference, to: :location_preference_list
      graph.add_edge from: :location_preference_list, to: :dynamic_location_preferences

      graph.add_conditional_edge(
        from: :dynamic_location_preferences,
        when: :applied_only_to_salaried_courses?,
        then: :funding_preference,
        else: :publish,
      )

      graph.add_edge from: :funding_preference, to: :publish

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
        when :invites
          helpers.candidate_interface_invites_path
        else
          helpers.candidate_interface_new_preferences_path(
            step: step_id,
            **options,
          )
        end
      },
    )
  end

  def steps_operator
    DfE::Wizard::StepsOperator::Builder.draw(wizard: self) do |builder|
      builder.on_step(
        :add_location_preference,
        add: [
          CandidateInterface::StepOperations::PreferencesWizard::AssignLocationPreference,
        ],
      )
      builder.on_step(
        :remove_location_preference,
        add: [
          CandidateInterface::StepOperations::PreferencesWizard::RemoveLocationPreference,
        ],
      )
      builder.on_step(
        :publish,
        add: [
          CandidateInterface::StepOperations::PreferencesWizard::SavePreference,
        ],
      )
    end
  end
end
