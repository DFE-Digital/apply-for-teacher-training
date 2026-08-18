module CandidateInterface
  module StateStores
    class CourseSelectionWizardStore
      include DfE::Wizard::StateStore

      attr_reader :current_application_id, :application_choice_id

      def edit?
        true
      end

      def know_the_course_to_apply?
        answer == 'yes'
      end

      def provider
        if provider_id.present?
          Provider.find(provider_id)
        else
          application_choice&.provider
        end
      end

      def provider_exists?
        provider.present?
      end

      def course
        if course_id.present?
          provider.courses.find(course_id)
        else
          application_choice&.course
        end
      end

      def current_application
        ApplicationForm.find(self[:current_application_id])
      end

      def existing_courses
        existing_courses = current_application.application_choices.joins(:course_option)
        existing_courses = existing_courses.where.not(id: self[:application_choice_id]) if self[:application_choice_id].present?
        existing_courses
      end

      def reapplication_limit_reached?
        CourseSelectionValidator.new.reached_reapplication_limit?(existing_courses, existing_courses.build(course:))
      end

      def duplicate_course?
        CourseSelectionValidator.new.exists_duplicate_application?(existing_courses, existing_courses.build(course:))
      end

      def course_closed?
        !course.open?
      end

      def course_unavailable?
        !course.application_status_open?
      end

      def not_multiple_sites_or_study_modes?
        !multiple_study_modes? && not_multiple_sites? && !visa_expires_soon?
      end

      def multiple_study_modes?
        course.currently_has_both_study_modes_available?
      end

      def multiple_sites?
        course.multiple_sites? && provider.selectable_school?
      end

      def not_multiple_sites?
        !multiple_sites?
      end

      def find_course_selected?
        confirm_answer? && completed?
      end

      def confirm_answer?
        ActiveModel::Type::Boolean.new.cast(confirm).present?
      end

      def application_choice
        current_application.application_choices.find(self[:application_choice_id])
      end

      def visa_expires_soon?
        application_choice.visa_expires_soon?
      end
    end
  end
end
