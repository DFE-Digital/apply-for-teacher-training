class CandidateInterface::CourseSelectionWizard
  include DfE::Wizard

  attr_accessor :current_application, :application_choice, :provider_id

  delegate :know_the_course_to_apply?,
           :reapplication_limit_reached?,
           :duplicate_course?,
           :course_closed?,
           :course_unavailable?,
           :multiple_study_modes?,
           :multiple_sites?,
           :not_multiple_sites?,
           :provider,
           :provider_exists?,
           :course,
           :course_id,
           :find_course_selected?,
           :find_course_not_selected?,
           :not_multiple_sites_or_study_modes?,
           :visa_expires_soon?,
           :not_confirmed?,
           to: :state_store

  def steps_processor
    DfE::Wizard::StepsProcessor::Graph.draw(self, predicate_caller: state_store) do |graph|
      graph.add_node :do_you_know_the_course, CandidateInterface::Steps::CourseSelectionWizard::DoYouKnowTheCourse
      graph.add_node :go_to_find_explanation, CandidateInterface::Steps::CourseSelectionWizard::GoToFindExplanation
      graph.add_node :provider_selection, CandidateInterface::Steps::CourseSelectionWizard::ProviderSelection
      graph.add_node :which_course_are_you_applying_to, CandidateInterface::Steps::CourseSelectionWizard::WhichCourseAreYouApplyingTo
      graph.add_node :duplicate_course_selection, CandidateInterface::Steps::CourseSelectionWizard::DuplicateCourseSelection
      graph.add_node :reached_reapplication_limit, CandidateInterface::Steps::CourseSelectionWizard::ReachedReapplicationLimit
      graph.add_node :full_course_selection, CandidateInterface::Steps::CourseSelectionWizard::FullCourseSelection
      graph.add_node :closed_course_selection, CandidateInterface::Steps::CourseSelectionWizard::ClosedCourseSelection
      graph.add_node :course_study_mode, CandidateInterface::Steps::CourseSelectionWizard::CourseStudyMode
      graph.add_node :course_site, CandidateInterface::Steps::CourseSelectionWizard::CourseSite
      graph.add_node :find_course_selection, CandidateInterface::Steps::CourseSelectionWizard::FindCourseSelection
      graph.add_node :visa_expiry_interruption, CandidateInterface::Steps::CourseSelectionWizard::VisaExpiryInterruption
      graph.add_node :visa_explanation, CandidateInterface::Steps::CourseSelectionWizard::VisaExplanation
      graph.add_node :course_review, CandidateInterface::Steps::CourseSelectionWizard::CourseReview
      graph.add_node :application_list, CandidateInterface::Steps::CourseSelectionWizard::ApplicationList

      graph.root :do_you_know_the_course

      graph.add_conditional_edge(
        from: :do_you_know_the_course,
        when: :know_the_course_to_apply?,
        then: :provider_selection,
        else: :go_to_find_explanation,
      )

      graph.add_edge from: :provider_selection, to: :which_course_are_you_applying_to

      graph.add_multiple_conditional_edges(
        from: :which_course_are_you_applying_to,
        branches: [
          { when: :reapplication_limit_reached?, then: :reached_reapplication_limit },
          { when: :duplicate_course?, then: :duplicate_course_selection },
          { when: :course_closed?, then: :closed_course_selection },
          { when: :course_unavailable?, then: :full_course_selection },
          { when: :not_multiple_sites_or_study_modes?, then: :course_review },
          { when: :multiple_study_modes?, then: :course_study_mode },
          { when: :multiple_sites?, then: :course_site },
          { when: :visa_expires_soon?, then: :visa_expiry_interruption },
        ],
        default: :course_review,
      )

      graph.add_multiple_conditional_edges(
        from: :course_study_mode,
        branches: [
          { when: :multiple_sites?, then: :course_site },
          { when: :visa_expires_soon?, then: :visa_expiry_interruption },
          { when: :not_multiple_sites?, then: :course_review },
        ],
        default: :course_study_mode,
      )

      graph.add_multiple_conditional_edges(
        from: :find_course_selection,
        branches: [
          { when: :multiple_study_modes?, then: :course_study_mode },
          { when: :multiple_sites?, then: :course_site },
          { when: :visa_expires_soon?, then: :visa_expiry_interruption },
          { when: :find_course_selected?, then: :course_review },
          { when: :not_confirmed?, then: :application_list },
        ],
        default: :course_review,
      )

      graph.add_conditional_edge(
        from: :course_site,
        when: :visa_expires_soon?,
        then: :visa_expiry_interruption,
        else: :course_review,
      )

      graph.add_edge from: :visa_expiry_interruption, to: :visa_explanation

      graph.add_edge from: :visa_explanation, to: :course_review
    end
  end

  def route_strategy
    DfE::Wizard::RouteStrategy::ConfigurableRoutes.new(
      wizard: self,
      namespace: 'candidate-interface-course-choices',
    ) do |config|
      config.map_step :which_course_are_you_applying_to, to: lambda { |wizard, options, helpers|
        options[:provider_id] = state_store.provider.id
        if wizard.application_choice.present?
          options[:application_choice_id] = wizard.application_choice.id
          helpers.candidate_interface_edit_course_choices_which_course_are_you_applying_to_path(**options)
        else
          helpers.candidate_interface_course_choices_which_course_are_you_applying_to_path(**options)
        end
      }

      config.map_step :course_study_mode, to: lambda { |wizard, options, helpers|
        options[:provider_id] = state_store.provider.id
        options[:course_id] = state_store.course.id
        if wizard.application_choice.present?
          options[:application_choice_id] = wizard.application_choice.id
          helpers.candidate_interface_edit_course_choices_course_study_mode_path(**options)
        else
          helpers.candidate_interface_course_choices_course_study_mode_path(**options)
        end
      }

      config.map_step :find_course_selection, to: lambda { |wizard, options, helpers|
        options[:course_id] = wizard.current_step.try(:course_id) || state_store.course.id
        helpers.candidate_interface_course_choices_course_confirm_selection_path(**options)
      }

      config.map_step :course_site, to: lambda { |wizard, options, helpers|
        options[:provider_id] = state_store.provider.id
        options[:course_id] = state_store.course.id
        options[:study_mode] = state_store.study_mode || course.available_study_modes_with_vacancies.first
        if wizard.application_choice.present?
          options[:application_choice_id] = wizard.application_choice.id
          helpers.candidate_interface_edit_course_choices_course_site_path(**options)
        else
          helpers.candidate_interface_course_choices_course_site_path(**options)
        end
      }

      config.map_step :course_review, to: lambda { |wizard, options, helpers|
        options[:application_choice_id] = wizard.application_choice.id
        helpers.candidate_interface_course_choices_course_review_path(**options)
      }

      config.map_step :duplicate_course_selection, to: lambda { |_wizard, options, helpers|
        options[:provider_id] = state_store.provider.id
        options[:course_id] = state_store.course.id
        options[:application_choice_id] = application_choice&.id
        helpers.candidate_interface_course_choices_duplicate_course_selection_path(**options)
      }

      config.map_step :closed_course_selection, to: lambda { |_wizard, options, helpers|
        options[:provider_id] = state_store.provider.id
        options[:course_id] = state_store.course.id
        options[:application_choice_id] = application_choice&.id
        helpers.candidate_interface_course_choices_closed_course_selection_path(**options)
      }

      config.map_step :full_course_selection, to: lambda { |_wizard, options, helpers|
        options[:provider_id] = state_store.provider.id
        options[:course_id] = state_store.course.id
        options[:application_choice_id] = application_choice&.id
        helpers.candidate_interface_course_choices_full_course_selection_path(**options)
      }

      config.map_step :visa_expiry_interruption, to: lambda { |wizard, options, helpers|
        options[:application_choice_id] = wizard.application_choice.id
        helpers.candidate_interface_course_choices_visa_expiry_interruption_path(**options)
      }

      config.map_step :visa_explanation, to: lambda { |wizard, options, helpers|
        options[:application_choice_id] = wizard.application_choice.id
        helpers.candidate_interface_course_choices_visa_explanation_path(**options)
      }

      config.map_step :reached_reapplication_limit, to: lambda { |_wizard, options, helpers|
        options[:provider_id] = state_store.provider.id
        options[:course_id] = state_store.course.id
        options[:application_choice_id] = application_choice&.id
        helpers.candidate_interface_course_choices_reached_reapplication_limit_path(**options)
      }

      config.map_step :application_list, to: lambda { |_wizard, options, helpers|
        helpers.candidate_interface_application_choices_path(**options)
      }
    end
  end

  def steps_operator
    DfE::Wizard::StepsOperator::Builder.draw(wizard: self) do |builder|
      builder.on_step(
        :which_course_are_you_applying_to,
        add: [
          CandidateInterface::StepOperations::CourseSelectionWizard::CreateApplicationChoice,
        ],
      )
      builder.on_step(
        :course_study_mode,
        add: [
          CandidateInterface::StepOperations::CourseSelectionWizard::CreateApplicationChoice,
        ],
      )
      builder.on_step(
        :course_site,
        add: [
          CandidateInterface::StepOperations::CourseSelectionWizard::CreateApplicationChoice,
        ],
      )
      builder.on_step(
        :find_course_selection,
        add: [
          CandidateInterface::StepOperations::CourseSelectionWizard::CreateApplicationChoice,
        ],
      )
      builder.on_step(
        :visa_explanation,
        add: [
          CandidateInterface::StepOperations::CourseSelectionWizard::UpdateApplicationChoiceVisa,
        ],
      )
    end
  end
end
