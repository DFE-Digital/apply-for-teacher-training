module CandidateInterface
  module ContinuousApplications
    class WhichCourseAreYouApplyingToStep < DfE::WizardStep
      include Concerns::CourseSelectionStepHelper
      attr_accessor :provider_id, :course_id
      validates :provider_id, :course_id, presence: true

      validates_with CourseSelectionValidator, on: :course_choice

      def self.permitted_params
        %i[provider_id course_id]
      end

      def available_courses
        @available_courses ||= GetAvailableCoursesForProvider.new(provider).call
      end

      def dropdown_available_courses
        ::CandidateInterface::PickCourseForm.new(provider_id:).dropdown_available_courses
      end

      def previous_step
        :provider_selection
      end

      def next_step
        return :course_review if completed?

        if duplicate_course?
          :duplicate_course_selection
        elsif multiple_study_modes?
          :course_study_mode
        elsif multiple_sites?
          :course_site
        end
      end

      def next_edit_step_path(next_step_klass)
        return next_step_path(next_step_klass) if next_step_klass == DuplicateCourseSelectionStep

        super
      end

      def next_step_path_arguments
        if completed?
          default_path_arguments
        elsif duplicate_course? || multiple_study_modes?
          { provider_id:, course_id: }
        elsif multiple_sites?
          { provider_id:, course_id:, study_mode: }
        end
      end

      def edit_next_step_path_arguments
        if completed?
          default_path_arguments
        elsif multiple_study_modes?
          default_path_arguments.merge(course_id:)
        elsif multiple_sites?
          default_path_arguments.merge(course_id:, study_mode:)
        end
      end

      def study_mode
        course.available_study_modes_with_vacancies.first
      end

      def completed?
        valid_course_choice && super
      end

    private

      def valid_course_choice
        @valid_course_choice ||= valid?(:course_choice)
      end

      def duplicate_course?
        !valid_course_choice
      end

      def default_path_arguments
        { application_choice_id: application_choice.id }
      end
    end
  end
end
