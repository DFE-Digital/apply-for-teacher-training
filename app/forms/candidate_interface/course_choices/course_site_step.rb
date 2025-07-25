module CandidateInterface
  module CourseChoices
    class CourseSiteStep < DfE::Wizard::Step
      include CandidateInterface::Concerns::CourseSelectionStepHelper

      attr_accessor :provider_id, :course_id, :study_mode, :course_option_id
      validates :course_option_id, presence: true

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

      def previous_step
        if multiple_study_modes?
          :course_study_mode
        else
          :which_course_are_you_applying_to
        end
      end

      def previous_step_path_arguments
        if multiple_study_modes?
          { provider_id:, course_id: }
        else
          { provider_id: }
        end
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
