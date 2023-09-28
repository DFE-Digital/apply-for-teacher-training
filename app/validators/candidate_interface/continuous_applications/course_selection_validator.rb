module CandidateInterface
  module ContinuousApplications
    # Validates that the course choice is not duplicated
    # Conditional exists to remove the course that is being edited from the checks for duplication
    class CourseSelectionValidator < ActiveModel::Validator
      def validate(record)
        @record = record

        return unless current_application

        scope = current_application.application_choices.joins(:course_option)
        scope = omit_current_application_choice(scope) if editing?
        exists = scope
                  .where({ status: ApplicationStateChange::NON_REAPPLY_STATUSES })
                  .exists?(course_option: { course_id: record.course.id })

        if exists
          @record.errors.add :base, 'You have already applied to this course'
        end
      end

      # Only validate against existing application choice that are not being edited
      def editing?
        return false unless @record.wizard.edit?

        course_id = @record.wizard.application_choice.course.id

        course_id == @record.course_id.to_i
      end

      def omit_current_application_choice(scope)
        scope.where.not({ course_option: { course_id: @record.course.id } })
      end

      def current_application
        @record.wizard.current_application
      end
    end
  end
end
