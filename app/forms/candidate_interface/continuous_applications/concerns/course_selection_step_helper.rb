module CandidateInterface
  module ContinuousApplications
    module Concerns
      module CourseSelectionStepHelper
        delegate :application_choice, to: :store

        def next_edit_step_path(next_step_klass)
          return next_step_path(next_step_klass) if %i[course_review reached_reapplication_limit].include?(next_step)

          route_name = next_step_klass.model_name.singular_route_key
          url_helpers.public_send(
            "candidate_interface_edit_continuous_applications_#{route_name}_path",
            edit_next_step_path_arguments,
          )
        end

        def completed?
          !multiple_study_modes? && !multiple_sites?
        end

        def multiple_study_modes?
          course.currently_has_both_study_modes_available?
        end

        delegate :multiple_sites?, to: :course

        def provider_exists?
          Provider.exists?(provider_id)
        end

        def provider
          @provider ||= Provider.find(provider_id)
        end

        def course
          @course ||= provider.courses.find(course_id)
        end
      end
    end
  end
end
