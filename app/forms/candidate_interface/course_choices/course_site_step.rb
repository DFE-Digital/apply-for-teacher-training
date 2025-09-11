module CandidateInterface
  module CourseChoices
    class CourseSiteStep < DfE::Wizard::Step
      include CandidateInterface::Concerns::CourseSelectionStepHelper

      attr_accessor :provider_id, :course_id, :study_mode, :course_option_id, :course_option_id_raw
      validates :course_option_id, presence: true
      validate :no_raw_input

      def self.permitted_params
        %i[provider_id course_id study_mode course_option_id course_option_id_raw]
      end

      def no_raw_input
        return if course_options.size < 20
        return if course_option_id.blank?

        return if site_options_for_select.any? do |name, id|
          course_option_id_raw == name && id == course_option_id.to_i
        end

        errors.add(:course_option_id, :blank)
      end

      def course_options
        @course_options ||= CourseOption
                              .available
                              .includes(:site)
                              .where(course_id:)
                              .where(study_mode:)
      end

      def available_sites
        course_options.sort_by { |course_option| course_option.site.name }
      end

      def site_options_for_select
        available_sites.map do |course_option|
          [
            "#{course_option.site.name} - #{course_option.site.full_address}",
            course_option.id,
          ]
        end.unshift([nil, nil])
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
