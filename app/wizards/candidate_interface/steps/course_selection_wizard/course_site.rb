module CandidateInterface
  module Steps
    class CourseSelectionWizard::CourseSite
      include DfE::Wizard::Step
      include CandidateInterface::Concerns::CourseSelectionStepHelper
      include FreeTextInputHelper

      delegate :provider, :provider_exists?, :state_store, :course, to: :wizard

      attribute :course_option_id
      attribute :course_option_id_raw

      validates :course_option_id, presence: true
      validate :no_free_text_input

      alias_attribute :value, :course_option_id
      alias_attribute :raw_input, :course_option_id_raw
      alias_attribute :valid_options, :site_options_for_select

      def self.permitted_params
        %i[course_option_id course_option_id_raw]
      end

      delegate :id, to: :course, prefix: true

      def study_mode
        state_store.study_mode.presence || course.available_study_modes_with_vacancies.first
      end

      def set_course_option_id
        # This handles if the user has changed course,
        # the previously selected site will still display,
        # but the course_option_id will be valid for the newly selected course
        return '' if course_option_id.blank?

        site = CourseOption.find_by(id: course_option_id)&.site
        return '' if site.blank?

        self.course_option_id = course_options.find_by(site:)&.id || ''
      end

      def no_free_text_input
        errors.add(:course_option_id, :blank) if invalid_raw_data?
      end

      def course_options
        @course_options ||= CourseOption.available.includes(:site).where(course_id:).where(study_mode:)
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
    end
  end
end
