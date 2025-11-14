module CandidateInterface
  module CourseChoices
    class CourseSiteStep < DfE::Wizard::Step
      include CandidateInterface::Concerns::CourseSelectionStepHelper
      include FreeTextInputHelper

      attr_accessor :provider_id, :course_id, :study_mode, :course_option_id, :course_option_id_raw
      validates :course_option_id, presence: true
      validate :no_free_text_input

      alias_attribute :value, :course_option_id
      alias_attribute :raw_input, :course_option_id_raw
      alias_attribute :valid_options, :site_options_for_select

      def self.permitted_params
        %i[provider_id course_id study_mode course_option_id course_option_id_raw]
      end

      def set_course_option_id
        # This handles if the user has changed course,
        # the previously selected site will still display,
        # but the course_option_id will be valid for the newly selected course
        return '' if @course_option_id.blank?

        site = CourseOption.find_by(id: @course_option_id)&.site
        return '' if site.blank?

        @course_option_id = course_options.find_by(site:)&.id || ''
      end

      def no_free_text_input
        errors.add(:course_option_id, :blank) if invalid_raw_data?
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
            course_option.site.name_and_address(' - '),
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
        { provider_id:, course_id: }
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
