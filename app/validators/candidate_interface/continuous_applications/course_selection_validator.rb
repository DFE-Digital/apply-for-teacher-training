module CandidateInterface
  module ContinuousApplications
    # Validates that the course choice is not duplicated
    # Conditional exists to remove the course that is being edited from the checks for duplication
    class CourseSelectionValidator < ActiveModel::Validator
      def validate(record)
        return unless record.wizard.current_application

        scope = record.wizard.current_application.application_choices.joins(:course_option)
        scope = omit_current_application_choice(scope, record) if editing?(record)
        exists = scope
          .where({ status: ApplicationStateChange.non_reapply_states })
                  .exists?(course_option: { course_id: record.course.id })

        if exists
          record.errors.add :base, 'You have already applied to this course'
        end
      end

      # Only validate against existing application choice that are not being edited
      def editing?(record)
        return false unless record.wizard.edit?

        course_id = record.wizard.application_choice.course.id

        course_id == record.course_id.to_i
      end

      def omit_current_application_choice(scope, record)
        scope.where.not({ id: record.wizard.application_choice.id })
      end
    end
  end
end
