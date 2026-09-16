module CandidateInterface
  module StateStores
    class CourseSelectionWizardStore
      include DfE::Wizard::StateStore

      attr_reader :current_application_id, :application_choice_id

      def know_the_course_to_apply?
        answer == 'yes'
      end

      def provider
        if provider_id.present?
          Provider.find_by(id: provider_id)
        elsif course_id.present?
          Course.find_by(id: course_id)&.provider
        else
          application_choice&.provider
        end
      end

      def provider_exists?
        provider.present?
      end

      def course
        if course_id.present?
          provider&.courses&.find_by(id: course_id)
        else
          application_choice&.course
        end
      end

      def current_application
        return if self[:current_application_id].blank?

        ApplicationForm.find_by(id: self[:current_application_id])
      end

      def existing_application_choices
        return ApplicationChoice.none if current_application.blank?

        existing_choices = current_application.application_choices.joins(:course_option)
        existing_choices = existing_choices.where.not(id: self[:application_choice_id]) if self[:application_choice_id].present?
        existing_choices
      end

      def reapplication_limit_reached?
        return false if course.blank?

        CourseSelectionValidator.new.reached_reapplication_limit?(
          existing_application_choices,
          existing_application_choices.build(course:),
        )
      end

      def duplicate_course?
        return false if course.blank?

        CourseSelectionValidator.new.exists_duplicate_application?(
          existing_application_choices,
          existing_application_choices.build(course:),
        )
      end

      def course_closed?
        course&.course_status_closed? || false
      end

      def course_unavailable?
        return false if course.blank?

        !course.available?
      end

      def not_multiple_sites_or_study_modes?
        !multiple_study_modes? && not_multiple_sites? && !visa_expires_soon?
      end

      def multiple_study_modes?
        course&.currently_has_both_study_modes_available? || false
      end

      def multiple_sites?
        (course&.multiple_sites? && provider&.selectable_school?) || false
      end

      def not_multiple_sites?
        !multiple_sites?
      end

      def find_course_selected?
        confirm_answer? && !multiple_study_modes? && !multiple_sites?
      end

      def not_confirmed?
        !confirm_answer?
      end

      def find_course_not_selected?
        !find_course_selected?
      end

      def confirm_answer?
        ActiveModel::Type::Boolean.new.cast(confirm).present?
      end

      def application_choice
        return if self[:application_choice_id].blank?

        current_application.application_choices.find(self[:application_choice_id])
      end

      def visa_expires_soon?
        return false if application_choice.blank?

        application_choice.visa_expires_soon?
      end
    end
  end
end
