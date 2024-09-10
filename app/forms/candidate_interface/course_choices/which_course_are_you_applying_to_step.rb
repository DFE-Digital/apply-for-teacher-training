module CandidateInterface
  module CourseChoices
    class WhichCourseAreYouApplyingToStep < DfE::Wizard::Step
      include CandidateInterface::Concerns::CourseSelectionStepHelper
      attr_accessor :provider_id, :course_id
      validates :provider_id, :course_id, presence: true

      validates_with CourseSelectionValidator, on: :course_choice

      def self.route_name
        'candidate_interface_course_choices_which_course_are_you_applying_to'
      end

      def self.permitted_params
        %i[provider_id course_id]
      end

      def available_courses
        @available_courses ||= GetAvailableCoursesForProvider.new(provider).call
      end

      def radio_available_courses
        ::CandidateInterface::PickCourseForm.new(provider_id:, available_courses:).radio_available_courses
      end

      def dropdown_available_courses
        ::CandidateInterface::PickCourseForm.new(provider_id:, available_courses:).dropdown_available_courses
      end

      def previous_step
        :provider_selection
      end

      def previous_step_path_arguments
        { provider_id: }
      end

      def next_step
        return :course_review if completed?

        if reapplication_limit_reached?
          :reached_reapplication_limit
        elsif duplicate_course?
          :duplicate_course_selection
        elsif course.application_status_closed?
          :closed_course_selection
        elsif !course.available?
          :full_course_selection
        elsif multiple_study_modes?
          :course_study_mode
        elsif multiple_sites?
          :course_site
        end
      end

      # When editing an application choice, we want to load the show path for
      # some steps that don't have an edit action / template
      def next_edit_step_path(next_step_klass)
        classes_without_edit = [DuplicateCourseSelectionStep, FullCourseSelectionStep, ClosedCourseSelectionStep]
        return next_step_path(next_step_klass) if classes_without_edit.include?(next_step_klass)

        super
      end

      def next_step_path_arguments
        if completed?
          default_path_arguments
        elsif duplicate_course? || reapplication_limit_reached? || !course.available? || course.application_status_closed? || multiple_study_modes?
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
        @valid_course_choice ||= !duplicate_course? && !reapplication_limit_reached? && course.available? && course.application_status_open?
      end

      def duplicate_course?
        course_choice_errors.include?(:duplicate_application_selection)
      end

      def reapplication_limit_reached?
        course_choice_errors.include?(:reached_reapplication_limit)
      end

      def course_choice_errors
        @course_choice_errors ||= begin
          valid?(:course_choice)
          errors.objects.map(&:type)
        end
      end

      def default_path_arguments
        { application_choice_id: application_choice.id }
      end
    end
  end
end
