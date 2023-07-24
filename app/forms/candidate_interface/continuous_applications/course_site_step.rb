module CandidateInterface
  module ContinuousApplications
    class CourseSiteStep < DfE::WizardStep
      include Concerns::CourseSelectionStepHelper
      attr_accessor :provider_id, :course_id, :study_mode, :course_option_id

      def self.permitted_params
        %i[provider_id course_id study_mode course_option_id]
      end

      def available_sites
        CourseOption
          .available
          .includes(:site)
          .where(course_id:)
          .where(study_mode:)
          .sort_by { |course_option| course_option.site.name }
      end

      def completed?
        true
      end

      def next_step
        :course_review
      end

      def next_step_path_arguments
        { application_choice_id: application_choice.id }
      end
    end
  end
end
