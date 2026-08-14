class CandidateInterface::CourseSelectionWizard
  include DfE::Wizard

  attr_accessor :current_application, :application_choice, :provider_id

  delegate :know_the_course_to_apply?,
           :completed?,
           :reapplication_limit_reached?,
           :duplicate_course?,
           :course_closed?,
           :course_unavailable?,
           :multiple_study_modes?,
           :multiple_schools?,
           :provider,
           to: :state_store

  def steps_processor
    DfE::Wizard::StepsProcessor::Graph.draw(self) do |graph|
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
          { when: :completed?, then: :course_review },
          { when: :multiple_study_modes?, then: :course_study_mode },
          { when: :multiple_schools?, then: :find_course_selection },
        ],
        default: :course_study_mode,
      )

      graph.add_conditional_edge(
        from: :course_study_mode,
        when: :completed?,
        then: :course_review,
        else: :find_course_selection,
      )

      graph.add_edge from: :find_course_selection, to: :course_review
    end
  end

  def route_strategy
    DfE::Wizard::RouteStrategy::ConfigurableRoutes.new(
      wizard: self,
      namespace: "candidate-interface-course-choices",
    ) do |config|
      config.map_step :which_course_are_you_applying_to, to: lambda { |_wizard, options, helpers|
        options[:provider_id] = state_store.provider_id
        helpers.candidate_interface_course_choices_which_course_are_you_applying_to_path(**options)
      }
    end
  end
end
