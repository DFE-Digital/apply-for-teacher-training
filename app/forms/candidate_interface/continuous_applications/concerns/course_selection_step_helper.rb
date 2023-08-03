module CandidateInterface
  module ContinuousApplications
    module Concerns
      module CourseSelectionStepHelper
        delegate :store, to: :wizard
        delegate :application_choice, to: :store

        def multiple_study_modes?
          course.currently_has_both_study_modes_available?
        end

        delegate :multiple_sites?, to: :course

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
