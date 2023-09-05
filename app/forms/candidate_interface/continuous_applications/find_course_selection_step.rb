module CandidateInterface
  module ContinuousApplications
    class FindCourseSelectionStep < DfE::WizardStep
      include Concerns::CourseSelectionStepHelper
      attr_accessor :course_id
      validates :course_id, presence: true

      delegate :find_url, :provider, :name_and_code, to: :course, prefix: true

      def self.permitted_params
        %i[course_id]
      end

      def next_step
        return :course_review if completed?

        if multiple_study_modes?
          :course_study_mode
        elsif multiple_sites?
          :course_site
        end
      end

      def next_step_path_arguments
        if completed?
          { application_choice_id: application_choice.id }
        elsif multiple_study_modes?
          { provider_id:, course_id: }
        elsif multiple_sites?
          { provider_id:, course_id:, study_mode: }
        end
      end

      def course
        Course.find(course_id)
      end
    end
  end
end
